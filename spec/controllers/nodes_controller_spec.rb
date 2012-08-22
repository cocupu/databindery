require 'spec_helper'

describe NodesController do
  describe "index" do
    before do
      @user = FactoryGirl.create :login_credential
      @model = FactoryGirl.create(:model, owner: @user.identities.first)
      @node1 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first, :associations=>{'authors'=>[1231, 2227], 'undefined'=>'123721'})
      @node2 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @different_pool_node = FactoryGirl.create(:node, model: @model )
      @different_model_node = FactoryGirl.create(:node, pool: @user.identities.first.pools.first )
      sign_in @user
    end
    it "should load the model and its nodes" do
      get :index, :model_id => @model
      response.should be_success
      assigns[:model].should be_kind_of Model
      assigns[:nodes].should include(@node1, @node2) 
      assigns[:nodes].should_not include(@different_pool_node) 
      assigns[:nodes].should_not include(@different_model_node) 
      assigns[:models].should == [@model] # for sidebar
    end
    it "should load all the nodes" do
      get :index
      response.should be_success
      assigns[:nodes].should include(@node1, @node2, @different_model_node) 
      assigns[:nodes].should_not include(@different_pool_node) 
      assigns[:models].should == [@model] # for sidebar
    end
    it "should respond with json" do
      get :index, :format=>'json'
      response.should be_success
      json = JSON.parse(response.body)
      json.map { |n| n["id"]}.should == [@node1.id, @node2.id, @different_model_node.id]
      json.first.keys.should include("data", 'associations', "id", "persistent_id", "model_id")
      json.first["associations"].should == {'authors'=>[1231, 2227], 'undefined'=>'123721'}
      #json.first["title"].should == @node1.title 
    end
  end

  describe "search" do
    before do
      @user = FactoryGirl.create :login_credential
      pool = @user.identities.first.pools.first
      @model = FactoryGirl.create(:model, owner: @user.identities.first, label: 'first_name',
                  fields: [{:code=>'first_name'}, {:code=>'last_name'}, {:code=>'title'}])
      @node1 = FactoryGirl.create(:node, model: @model, pool: pool, :data=>{'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'})
      @node2 = FactoryGirl.create(:node, model: @model, pool: pool, :data=>{'first_name'=>'Matt', 'last_name'=>'Zumwalt', 'title'=>'Mr.'})
      @different_pool_node = FactoryGirl.create(:node, model: @model )
      @different_model_node = FactoryGirl.create(:node, pool: pool)
      sign_in @user
    end
    it "when model is not provided" do
      get :search, :format=>'json'
      response.should be_success
      json = JSON.parse(response.body)
      json.map { |n| n["id"]}.should == [@node1.id, @node2.id, @different_model_node.id]
      json.first.keys.should include("data", 'associations', "id", "persistent_id", "model_id")
      json.first["data"].should == {'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'}
    end
    it "when model is provided" do
      get :search, :format=>'json', :model_id=>@model.id
      response.should be_success
      json = JSON.parse(response.body)
      json.map { |n| n["id"]}.should == [@node1.id, @node2.id]
      json.first["data"].should == {'first_name'=>'Justin', 'last_name'=>'Coyne', 'title'=>'Mr.'}
    end
  end


  describe "show" do
    before do
      @user = FactoryGirl.create :login_credential
      @model = FactoryGirl.create(:model, owner: @user.identities.first)
      @node1 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @node2 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @different_pool_node = FactoryGirl.create(:node, model: @model )
      @different_model_node = FactoryGirl.create(:node, pool: @user.identities.first.pools.first )
      sign_in @user
    end
    it "should load the node and the models" do
      get :show, :id => @node1
      response.should be_success
      assigns[:models].should == [@model] # for sidebar
      assigns[:node].should == @node1 
    end
    it "should respond with json" do
      get :show, :id => @node1, :format=>'json'
      response.should be_success
      response.body.should == @node1.to_json
    end
    it "should not load node we don't have access to" do
      get :show, :id => @different_pool_node 
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

  describe "new" do
    before do
      @user = FactoryGirl.create :login_credential
      @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
      @not_my_model = FactoryGirl.create(:model)
      sign_in @user
    end
    it "should be successful when a binding is passed" do 
      get :new, :binding => '0B4oXai2d4yz6bUstRldTeXV0dHM'
      response.should be_success
      assigns[:node].should be_kind_of Node
      assigns[:node].binding.should == '0B4oXai2d4yz6bUstRldTeXV0dHM'
      assigns[:models].should == [@my_model]
      response.should render_template :new_binding
    end
    it "should be successful when a readable model is passed" do 
      get :new, :model_id => @my_model
      response.should be_success
      assigns[:node].should be_kind_of Node
      assigns[:node].model.should == @my_model
      assigns[:models].should == [@my_model] # for sidebar
    end
    it "should be redirect when an unreadable model is passed" do 
      get :new, :model_id => @not_my_model
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

  describe "create" do
    before do
      @user = FactoryGirl.create :login_credential
      @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
      @not_my_model = FactoryGirl.create(:model)
      sign_in @user
    end
    it "should be successful using a model I own" do 
      post :create, :node=>{:binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', :model_id=>@my_model}
      response.should redirect_to node_path(assigns[:node])
      assigns[:node].binding.should == '0B4oXai2d4yz6bUstRldTeXV0dHM'
      assigns[:node].model.should == @my_model
      flash[:notice].should == "#{@my_model.name} created"
    end
    it "should not be successful using a model I don't own" do 
      post :create, :node=>{:binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', :model_id=>@not_my_model}
      response.should redirect_to new_node_path(:binding=>'0B4oXai2d4yz6bUstRldTeXV0dHM')
      assigns[:node].model.should be_nil
      
    end
  end

  describe "update" do
    before do
      @user = FactoryGirl.create :login_credential
      @model = FactoryGirl.build(:model, owner: @user.identities.first)
      @model.fields = [{code: 'f1', name: 'Field one'}]
      @model.save!
      @node1 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @node2 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @different_pool_node = FactoryGirl.create(:node, model: @model )
      @different_model_node = FactoryGirl.create(:node, pool: @user.identities.first.pools.first )
      sign_in @user
    end
    it "should load the node and the models" do
      put :update, :id => @node1, :node=>{:data=>{ 'f1' => 'Updated val' }}
      new_version = Node.latest_version(@node1.persistent_id)
      response.should redirect_to node_path(new_version)
      new_version.data['f1'].should == "Updated val"
      flash[:notice].should == "#{@model.name} updated"
      
    end
    it "should not load node we don't have access to" do
      put :update, :id => @different_pool_node, :node=>{:data=>{ }}
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
    
  end

end
