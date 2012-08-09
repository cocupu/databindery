require 'spec_helper'

describe NodesController do
  describe "index" do
    before do
      @user = FactoryGirl.create :login_credential
      @model = FactoryGirl.create(:model, owner: @user.identities.first)
      @node1 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @node2 = FactoryGirl.create(:node, model: @model, pool: @user.identities.first.pools.first)
      @different_pool_node = FactoryGirl.create(:node, model: @model )
      @different_model_node = FactoryGirl.create(:node, pool: @user.identities.first.pools.first )
      sign_in @user
    end
    it "should load the model and its nodes" do
      get :index, :model_id => @model.id
      response.should be_success
      assigns[:model].should be_kind_of Model
      assigns[:nodes].should include(@node1, @node2) 
      assigns[:nodes].should_not include(@different_pool_node) 
      assigns[:nodes].should_not include(@different_model_node) 
    end
  end

  describe "new" do
    before do
      @user = FactoryGirl.create :login_credential
      sign_in @user
    end
    it "should be successful" do 
      get :new, :binding => '0B4oXai2d4yz6bUstRldTeXV0dHM'
      response.should be_success
      assigns[:node].should be_kind_of Node
      assigns[:node].binding.should == '0B4oXai2d4yz6bUstRldTeXV0dHM'
    end
  end


end
