require 'spec_helper'

describe PoolSearchesController do
  before do
    @identity = FactoryGirl.create :identity
    @my_pool = FactoryGirl.create :pool, :owner=>@identity
    @not_my_pool = FactoryGirl.create(:pool)
  end
  
  describe "index" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :index, pool_id: @my_pool, identity_id: @identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
        @my_model = FactoryGirl.create(:model, pool: @identity.pools.first)
        @other_pool = FactoryGirl.create(:pool, owner: @identity)
        @my_model_different_pool = FactoryGirl.create(:model, pool: @other_pool)
        @not_my_model = FactoryGirl.create(:model)
      end
      describe "requesting a pool I don't own" do
        it "should redirect to root" do
          get :index, :pool_id=>@not_my_pool, identity_id: @identity.short_name
          response.should redirect_to( root_path )
        end
      end
      describe "requesting a pool I own" do
        it "should be successful" do
          get :index, :pool_id=>@my_pool, identity_id: @identity.short_name
          response.should be_success
        end
        it "should apply filters and facets from exhibit" do
          exhibit_with_filters = FactoryGirl.build(:exhibit, pool: @my_pool, filters_attributes: [field_name:"subject", operator:"-", values:["test", "barf"]])
          exhibit_with_filters.save!
          get :index, :pool_id=>@my_pool, :perspective=>exhibit_with_filters.id, identity_id: @identity.short_name
          subject.exhibit.should == exhibit_with_filters
          subject.solr_search_params[:fq].should include('-subject_t:"test"', '-subject_t:"barf"')
        end
      end
      describe "requesting a pool I don't own but have edit access to" do
        before do
          @other_identity = FactoryGirl.create(:identity)
          AccessControl.create!(:pool=>@my_pool, :identity=>@other_identity, :access=>'EDIT')
        end
        it "should be successful when rendering json" do
          pending "TODO: enable JSON API on Blacklight-based searches"
          get :index, :pool_id=>@my_pool, :format=>:json, identity_id: @identity.short_name
          response.should  be_successful
          json = JSON.parse(response.body)
          json['id'].should == @my_pool.id
          json['access_controls'].should == [{'identity' => @other_identity.short_name, 'access'=>'EDIT'} ]
        end
      end
    end
  end
  
  describe "show" do
    before do
      @node = FactoryGirl.create(:node, pool: @my_pool)
    end
    describe "when signed in" do
      before do
        sign_in @identity.login_credential
      end
      it "should be success" do
        get :show, id: @node.persistent_id, :pool_id=>@my_pool, identity_id: @identity.short_name      
        response.should be_successful
      end
    end
    describe "when not signed in" do
      describe "show" do
        it "should not be successful" do
          get :show, id: @node.persistent_id,  :pool_id=>@my_pool, identity_id: @identity.short_name        
          response.should redirect_to root_path          
        end
        it "should return 401 to json API" do
          get :show, id: @node.persistent_id,  :pool_id=>@my_pool, :format=>:json, identity_id: @identity.short_name        
          response.code.should == "401"     
        end
      end
    end
  end
end