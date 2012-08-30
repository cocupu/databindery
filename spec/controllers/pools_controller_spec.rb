require 'spec_helper'

describe PoolsController do
  before do
    @user = FactoryGirl.create :login
    @my_pool = @user.identities.first.pools.first
    @not_my_pool = FactoryGirl.create(:pool)
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index }
      it "should show nothing" do
        response.should  be_successful
        assigns[:pools].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @user
      end
      it "should be successful" do
        get :index 
        response.should  be_successful
        assigns[:pools].should == [@my_pool]
      end
    end
  end

  describe "show" do
    describe "when not logged on" do
      subject { get :show, :id=>@my_pool }
      it "should show nothing" do
        response.should  be_successful
        assigns[:pools].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @user
        @my_model = FactoryGirl.create(:model, pool: @user.identities.first.pools.first)
        @other_pool = FactoryGirl.create(:pool, owner: @user.identities.first)
        @my_model_different_pool = FactoryGirl.create(:model, pool: @other_pool)
        @not_my_model = FactoryGirl.create(:model)
      end
      describe "requesting a pool I don't own" do
        it "should redirect to root" do
          get :show, :id=>@not_my_pool
          response.should redirect_to root_path
        end
      end
      describe "requesting a pool I own" do
        it "should be successful" do
          get :show, :id=>@my_pool
          response.should  be_successful
          assigns[:pool].should == @my_pool
          assigns[:models].should include(@my_model)
          assigns[:models].should_not include(@my_model_different_pool) 
        end
      end
      describe "requesting a pool I own" do
        it "should be successful when rendering json" do
          get :show, :id=>@my_pool, :format=>:json
          response.should  be_successful
          json = JSON.parse(response.body)
          json['id'].should == @my_pool.id
        end
      end
    end
  end

  describe "create" do
    describe "when not logged on" do
      it "should redirect to home" do
        post :create, :pool=>{:name=>"New Pool"} 
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        sign_in @user
        # @my_model = FactoryGirl.create(:model, pool: @user.identities.first.pools.first)
        # @not_my_model = FactoryGirl.create(:model)
      end
      it "should be successful when rendering json" do
        post :create, :pool=>{:name=>"New Pool"}, :format=>:json 
        response.should  be_successful
        json = JSON.parse(response.body)
        json['owner_id'].should == @user.identities.first.id
        json['name'].should == "New Pool"
      end
    end
  end
end
