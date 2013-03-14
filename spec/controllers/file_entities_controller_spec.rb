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
    describe "if target_node provided" do
      before do
        @node_to_target = FactoryGirl.create(:node, pool: @pool)
      end
      it "should add to file list of target_node" do
        post :create, :format=>:json, :binding=>'1231249', :pool_id=>@pool.short_name, :identity_id=>@identity.short_name, :target_node_id=>@node_to_target.persistent_id
        target_node = Node.latest_version(@node_to_target.persistent_id)
        target_node.files.last.should == assigns[:file_entity]
      end
    end
    it "should work with info posted by S3 Direct Upload" do
      params_from_s3_direct_upload = {:pool_id=>@pool.short_name, :identity_id=>@identity.short_name, "url"=>"https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg", "filepath"=>"/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg", "filename"=>"DSC_0549-3.jpg", "filesize"=>"471990", "filetype"=>"image/jpeg", "binding"=>"https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"}
      post :create, params_from_s3_direct_upload
      response.should be_successful
      file_entity = assigns[:file_entity]
      file_entity.binding.should == "https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.storage_location_id.should == "/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.file_name.should == "DSC_0549-3.jpg"
      file_entity.file_size.should == "471990"
      file_entity.mime_type.should == "image/jpeg"
      file_entity.pool.should == @pool
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
