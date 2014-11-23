require 'spec_helper'

describe NodesController do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool) { FactoryGirl.create :pool, owner:identity }
  let(:not_my_pool) { FactoryGirl.create :pool }

  let(:first_name_field) {Field.create(name:'first_name', 'multivalue' => false)}
  let(:last_name_field) {Field.create(name:'last_name')}
  let(:title_field) {Field.create(name:'title', multivalue:true)}

  let(:model) { FactoryGirl.create(:model, pool:pool, label_field:first_name_field,
                                   fields: [first_name_field, last_name_field, title_field]) }
  let(:not_my_model) { FactoryGirl.create(:model) }

  describe "index" do
    before do
      @node1 = FactoryGirl.create(:node, model:model, pool:pool, :associations=>{'authors'=>[1231, 2227], 'undefined'=>'123721'})
      @node2 = FactoryGirl.create(:node, model:model, pool:pool)
      @different_pool_node = FactoryGirl.create(:node, model:model )
      @different_model_node = FactoryGirl.create(:node, pool:pool )
      sign_in identity.login_credential
    end
    it "should load the model and its nodes" do
      get :index, :model_id => model, pool_id: pool, identity_id: identity
      response.should be_success
      assigns[:model].should == model
      assigns[:nodes].should include(@node1, @node2) 
      assigns[:nodes].should_not include(@different_pool_node) 
      assigns[:nodes].should_not include(@different_model_node) 
      assigns[:models].should == [model] # for sidebar
    end
    it "should load all the nodes" do
      get :index, pool_id: pool, identity_id: identity
      response.should be_success
      assigns[:nodes].should include(@node1, @node2, @different_model_node) 
      assigns[:nodes].should_not include(@different_pool_node) 
      assigns[:models].should == [model] # for sidebar
    end
    it "should respond with json" do
      get :index, :format=>'json', pool_id: pool, identity_id: identity
      response.should be_success
      json = JSON.parse(response.body)
      json.map { |n| n["id"]}.should == [ @different_model_node.persistent_id, @node2.persistent_id, @node1.persistent_id]
      json.last.keys.should include("data", 'associations', "id", "persistent_id", "model_id")
      json.last["associations"].should == {'authors'=>[1231, 2227], 'undefined'=>'123721'}
      #json.first["title"].should == @node1.title 
    end
  end

  describe "search" do
    before do
      @node1 = FactoryGirl.create(:node, model: model, pool: pool, :data=>{first_name_field.id.to_s =>'Justin', last_name_field.id.to_s=>'Coyne', title_field.id.to_s=>'Mr.'})
      @node2 = FactoryGirl.create(:node, model: model, pool: pool, :data=>{first_name_field.id.to_s=>'Matt', last_name_field.id.to_s=>'Zumwalt', title_field.id.to_s=>'Mr.'})
      @different_pool_node = FactoryGirl.create(:node, model: model )
      @different_model_node = FactoryGirl.create(:node, pool: pool)
      sign_in identity.login_credential
    end
    describe "when model is not provided" do
      it "should query everything" do
        get :search, :format=>'json', :pool_id => pool, identity_id: identity.short_name
        response.should be_success
        json = JSON.parse(response.body)
        json.map { |n| n["id"]}.should == [@node1.persistent_id, @node2.persistent_id, @different_model_node.persistent_id]
        json.first.keys.should include("data", 'associations', "id", "persistent_id", "model_id")
        json.first["data"].should == @node1.data
      end
    end
    describe "when query is  provided" do
      it "should find nodes that match the query" do
        get :search, :format=>'json', :q=>'Coyne', :pool_id => pool, identity_id: identity.short_name
        response.should be_success
        json = JSON.parse(response.body)
        json.map { |n| n["id"]}.should == [@node1.persistent_id]
        json.first.keys.should include("data", 'associations', "id", "persistent_id", "model_id")
        json.first["data"].should == @node1.data
      end
    end
    describe "when model is provided" do
      it "should only find nodes with that model" do
        get :search, :format=>'json', :model_id=>model.id, :pool_id => pool, identity_id: identity.short_name
        response.should be_success
        json = JSON.parse(response.body)
        json.map { |n| n["id"]}.should == [@node1.persistent_id, @node2.persistent_id]
        json.first["data"].should == @node1.data
      end
    end
  end


  describe "show" do
    before do
      @node1 = FactoryGirl.create(:node, model:model, pool:pool)
      @node2 = FactoryGirl.create(:node, model:model, pool:pool)
      @different_pool_node = FactoryGirl.create(:node, model:model )
      @different_model_node = FactoryGirl.create(:node, pool:pool )
      sign_in identity.login_credential
    end
    it "should load the node and the models" do
      pending "Adjust this test for mp3 and ogg"
      get :show, :id => @node1.persistent_id, pool_id:pool, identity_id:identity
      response.should be_success
      assigns[:models].should == [model] # for sidebar
      assigns[:node].should == @node1 
    end
    it "should respond with json" do
      get :show, :id => @node1.persistent_id, :format=>'json', pool_id:pool, identity_id:identity
      response.should be_success
      JSON.parse(response.body).should == { "title"=>@node1.title, "modified_by_id" => nil,"node_version_id"=>@node1.id, "persistent_id" => @node1.persistent_id, "spawned_from_datum_id"=>nil, "spawned_from_node_id"=>nil, "url" => identity_pool_node_path(identity, pool, @node1), "pool"=>pool.short_name, "identity"=>identity.short_name, "is_fork" => false, "log" => nil, "binding"=>nil, "model_id"=>@node1.model_id, "associations"=>{}, "data"=>{} }
    end
    it "should not load node we don't have access to" do
      get :show, :id => @different_pool_node.persistent_id, pool_id:pool, identity_id:identity
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
  end
  
  describe "find_or_create" do
    before do
      @node1 = FactoryGirl.create(:node, model: model, pool: pool, :data=>{first_name_field.id.to_s=>'Justin', last_name_field.id.to_s=>'Coyne', title_field.id.to_s=>'Mr.'})
      @node2 = FactoryGirl.create(:node, model: model, pool: pool, :data=>{first_name_field.id.to_s=>'Matt', last_name_field.id.to_s=>'Zumwalt', title_field.id.to_s=>'Mr.'})
      @node3 = FactoryGirl.create(:node, model: model, pool: pool, :data=>{first_name_field.id.to_s=>'Justin', last_name_field.id.to_s=>'Ball', title_field.id.to_s=>'Mr.'})
      sign_in identity.login_credential
    end
    it "should not be successful using a pool I can't edit" do       
      post :find_or_create, :node => {:model_id=>model, :data=>{first_name_field.id.to_s =>"Justin", last_name_field.id.to_s => "Coyne"}}, pool_id: not_my_pool, identity_id: identity.short_name
      response.code.should == '404'
      assigns[:node].should be_nil
    end
    it "should return existing node node if one already fits the fields & values specified" do
      previous_number_of_nodes = Node.count
      post :find_or_create, :node => {:model_id=>model, :data=>{first_name_field.id.to_s =>"Justin", last_name_field.id.to_s => "Coyne"}}, pool_id: pool, identity_id: identity.short_name
      Node.count.should == previous_number_of_nodes
      assigns[:node].data.should == @node1.data
      assigns[:node].model.should == model
      flash[:notice].should == "Found a #{model.name} matching your query."
    end
    it "should create a new node if none fits the fields & values specified" do
      previous_number_of_nodes = Node.count
      post :find_or_create, :node => {:model_id=>model, :data=>{first_name_field.id.to_s =>"Randy", last_name_field.id.to_s => "Reckless"}}, pool_id: pool, identity_id: identity.short_name
      Node.count.should == previous_number_of_nodes + 1
      assigns[:node].data.should == {first_name_field.id.to_s=>"Randy", last_name_field.id.to_s=>"Reckless"}
      assigns[:node].model.should == model
      flash[:notice].should == "Created a new #{model.name} based on your request."
    end
    it "should return json" do 
      post :find_or_create, :node => {:model_id=>model, :data=>{first_name_field.id.to_s =>"Justin", last_name_field.id.to_s => "Coyne"}}, pool_id: pool, identity_id: identity, :format=>:json
      response.should be_success
      JSON.parse(response.body).keys.should include('persistent_id', 'model_id', 'url', 'pool', 'identity', 'associations', 'binding')
      model.nodes.count.should == 3
      model.nodes.first.data.should == {first_name_field.id.to_s=>"Justin", last_name_field.id.to_s=>"Ball", title_field.id.to_s=>"Mr."}
    end
  end

  describe "new" do
    before do
      sign_in identity.login_credential
    end
    it "should be successful when a binding is passed" do 
      get :new, :binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', pool_id: pool, identity_id: identity
      response.should be_success
      assigns[:node].should be_kind_of Node
      assigns[:node].binding.should == '0B4oXai2d4yz6bUstRldTeXV0dHM'
      assigns[:models].should == [model]
      response.should render_template :new_binding
    end
    it "should be successful when a readable model is passed" do 
      get :new, :model_id => model, pool_id: pool, identity_id: identity
      response.should be_success
      assigns[:node].should be_kind_of Node
      assigns[:node].model.should == model
      assigns[:models].should == [model] # for sidebar
    end
    it "should be redirect when an unreadable model is passed" do 
      get :new, :model_id => not_my_model, pool_id: pool, identity_id: identity
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

  describe "create" do
    before do
      sign_in identity.login_credential
    end
    it "should be successful using a model I own" do 
      post :create, :node=>{:binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', :model_id=>model}, pool_id: pool, identity_id: identity.short_name
      response.should redirect_to identity_pool_search_path(identity, pool)
      assigns[:node].binding.should == '0B4oXai2d4yz6bUstRldTeXV0dHM'
      assigns[:node].model.should == model
      flash[:notice].should == "#{model.name} created"
    end
    it "should not be successful using a model I don't own" do 
      post :create, :node=>{:binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', :model_id=>not_my_model}, pool_id: pool, identity_id: identity.short_name
      response.should redirect_to new_identity_pool_node_path(identity, pool, :binding=>'0B4oXai2d4yz6bUstRldTeXV0dHM')
      assigns[:node].model.should be_nil
    end
    it "should set modified_by on the node it creates" do
      post :create, :node=>{:binding => '0B4oXai2d4yz6bUstRldTeXV0dHM', :model_id=>model}, pool_id: pool, identity_id: identity.short_name
      assigns[:node].modified_by.should == identity
    end
    it "should return json" do 
      post :create, :node=>{:data=> {first_name_field.id.to_s => 'New val'}, :associations=>{'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']},  :model_id=>model}, pool_id: pool, identity_id: identity, :format=>:json
      response.should be_success
      JSON.parse(response.body).keys.should include('persistent_id', 'model_id', 'url', 'pool', 'identity', 'associations', 'binding')
      model.nodes.count.should == 1
      model.nodes.first.data.should == {first_name_field.id.to_s => 'New val'}
      model.nodes.first.associations.should == {'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']}
    end
  end

  describe "update" do
    before do
      @node1 = FactoryGirl.create(:node, model: model, pool:pool)
      @node2 = FactoryGirl.create(:node, model: model, pool:pool)
      @different_pool_node = FactoryGirl.create(:node, model: model )
      @different_model_node = FactoryGirl.create(:node, pool:pool )
      sign_in identity.login_credential
    end
    it "should load the node and the models" do
      put :update, :id => @node1.persistent_id, :node=>{data:{ first_name_field.id.to_s => 'Updated val' }, associations:{foo:@node2.persistent_id}}, pool_id: pool, identity_id: identity
      new_version = Node.latest_version(@node1.persistent_id)
      response.should redirect_to identity_pool_solr_document_path(identity, pool, new_version)
      new_version.data[first_name_field.id.to_s].should == "Updated val"
      new_version.associations['foo'].should == @node2.persistent_id
      flash[:notice].should == "#{model.name} updated"
    end
    it "should not load node we don't have access to" do
      put :update, :id => @different_pool_node.persistent_id, :node=>{:data=>{ }}, pool_id: pool, identity_id: identity
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
    it "should set modified_by on the node version it creates" do
      put :update, :id => @node1.persistent_id, :node=>{:data=>{ first_name_field.id.to_s => 'Updated val' }}, pool_id: pool, identity_id: identity
      assigns[:node].modified_by.should == identity
    end
    it "should accept json without fields wrapped in a :node hash" do
      put :update, :id => @node1.persistent_id, :format=>'json', pool_id: pool, identity_id: identity, :data=>{ first_name_field.id.to_s => 'Updated val' }, :associations=>{'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']}
      new_version = Node.latest_version(@node1.persistent_id)
      response.code.should == "204" # no content
      new_version.data[first_name_field.id.to_s].should == "Updated val"
      new_version.associations.should == {'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']}
    end
    it "should not show anything for json" do
      put :update, :id => @node1.persistent_id, :node=>{:data=>{ first_name_field.id.to_s => 'Updated val' }, :associations=>{'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']}}, :format=>'json', pool_id: pool, identity_id: identity
      new_version = Node.latest_version(@node1.persistent_id)
      response.code.should == "204" # no content
      new_version.data[first_name_field.id.to_s].should == "Updated val"
      new_version.associations.should == {'talk' => ['68a9ae10-ea2d-012f-5e29-3c075405d3d7']}
    end
    
  end

  describe "import" do
    before do
      sign_in identity.login_credential
    end
    it "should import nodes from an array of data records" do
      r1 = { first_name_field.id.to_s => 'A val' }
      r2 = { first_name_field.id.to_s => 'Another val' }
      nodes_before = Node.count
      post :import, :data=>[r1, r2], :model_id=>model, pool_id: pool, identity_id: identity.short_name
      expect(Node.count).to eq(nodes_before + 2)
      expect(Node.last.data).to eq(r1)
      expect(Node.find(Node.last.id+1).data).to eq(r2)
    end
  end

  describe "attach_file" do
    before do
      config = YAML.load_file(Rails.root + 'config/s3.yml')[Rails.env]
      @s3 = FactoryGirl.create(:s3_connection, config.merge(pool: pool))
      @node = FactoryGirl.create(:node, model:model, pool:pool)
      sign_in identity.login_credential
    end
    it "should route" do
      identity_pool_node_files_path('my_ident', 'my_pool', 567).should == "/my_ident/my_pool/nodes/567/files"
    end
    it "should upload files" do
      post :attach_file, pool_id: pool, identity_id: identity, 
        node_id: @node.persistent_id, file_name: "rails.png",
        file: fixture_file_upload('/images/rails.png', 'image/png', true)
      node = Node.latest_version(@node.persistent_id)
      response.should redirect_to identity_pool_node_path(identity, pool, node)
        
      file_node = Node.latest_version(node.files.first.persistent_id)
      file_node.file_name.should == 'rails.png'
    end
  end
  
  describe "delete" do
    before do
      @node1 = FactoryGirl.create(:node, model: model, pool: pool)
      @node2 = FactoryGirl.create(:node, model: model, pool: pool)
      @different_pool_node = FactoryGirl.create(:node, model: model )
      @different_model_node = FactoryGirl.create(:node, pool: pool )
    end
    describe "when not logged on" do
      subject { delete }
      it "should redirect to root" do
        delete :destroy, :id=>@node1, pool_id: pool, identity_id: identity
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in identity.login_credential
      end
      it "should redirect on a node that's not in a pool I have access to" do
        delete :destroy, :id=>@different_pool_node, pool_id: pool, identity_id: identity
        response.should redirect_to root_path
        flash[:alert].should == "You are not authorized to access this page."
      end
      
      it "should be able to delete a node" do
        node_id = @node1.persistent_id
        node_label = @node1.title
        delete :destroy, :id=>@node1, pool_id: pool, identity_id: identity
        response.should redirect_to identity_pool_search_path(identity, pool)
        flash[:notice].should == "Deleted \"#{node_label}\"."
        lambda{Model.find(node_id)}.should raise_exception ActiveRecord::RecordNotFound
      end
    end
  end

end
