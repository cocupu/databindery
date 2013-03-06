require 'spec_helper'

describe FileEntitiesController do

  describe 'create' do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
      sign_in @identity.login_credential
    end
    it "should create and return json" do
      post :create, :format=>:json, :binding=>'1231249', :pool_id=>@pool.short_name, :identity_id=>@identity.short_name
      response.should be_successful
      json = JSON.parse(response.body)
      json.keys.should include('id')
    end
  end
  
  describe "new" do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
      @node_to_target = FactoryGirl.create(:node, pool: @pool)
      # "Not my stuff":
      @not_me = FactoryGirl.create :identity
      @not_my_pool = FactoryGirl.create :pool, :owner=>@not_me
      @not_my_node = FactoryGirl.create(:node, pool: @not_my_pool)
      sign_in @identity.login_credential
    end
    
    it "should be successful without (optional) target node" do
      get :new, pool_id: @pool.short_name, identity_id: @identity.short_name
      response.should be_success
      assigns[:target_node].should be_nil
      S3DirectUpload.config.bucket.should == @pool.persistent_id
    end
    it "should load target node if node is readable" do
      get :new, :model_id => @my_model, pool_id: @pool.short_name, identity_id: @identity.short_name, target_node_id: @node_to_target.persistent_id
      response.should be_success
      assigns[:target_node].should == @node_to_target
      assigns[:pool].should == @pool
      S3DirectUpload.config.bucket.should == @pool.persistent_id
    end
    it "should not load target node if unreadable" do
      get :new, :model_id => @my_model, pool_id: @pool.short_name, identity_id: @identity.short_name, target_node_id: @not_my_node.persistent_id
      response.should be_success
      assigns[:target_node].should be_nil
      S3DirectUpload.config.bucket.should == @pool.persistent_id
    end
    it "should be redirect when pool is not editable" do 
      get :new, pool_id: @not_my_pool.short_name, identity_id: @not_me.short_name
      response.should redirect_to root_path
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

end
