require 'spec_helper'

describe PoolsController do
  before do
    @identity = FactoryGirl.create :identity
    @my_pool = FactoryGirl.create :pool, :owner=>@identity
    @not_my_pool = FactoryGirl.create(:pool)
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index, identity_id: @identity.short_name }
      it "should show nothing" do
        response.should  be_successful
        assigns[:pools].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :index, identity_id: @identity.short_name
        response.should  be_successful
        assigns[:pools].should == [@my_pool]
      end
      it "should return json" do
        get :index, identity_id: @identity.short_name, format: :json
        response.should be_successful
        JSON.parse(response.body).should == [{"short_name"=>@my_pool.short_name, "url"=>"/#{@identity.short_name}/#{@my_pool.short_name}"}]
      end
    end
  end

  describe "show" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :show, id: @my_pool, identity_id: @identity.short_name
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
          get :show, :id=>@not_my_pool, identity_id: @identity.short_name
          response.should be_not_found
        end
      end
      describe "requesting a pool I own" do
        it "should be successful" do
          get :show, :id=>@my_pool, identity_id: @identity.short_name
          response.should  be_successful
          assigns[:pool].should == @my_pool
          assigns[:models].should include(@my_model)
          assigns[:models].should_not include(@my_model_different_pool) 
        end
      end
      describe "requesting a pool I own" do
        before do
          @other_identity = FactoryGirl.create(:identity)
          AccessControl.create!(:pool=>@my_pool, :identity=>@other_identity, :access=>'EDIT')
        end
        it "should be successful when rendering json" do
          get :show, :id=>@my_pool, :format=>:json, identity_id: @identity.short_name
          response.should  be_successful
          json = JSON.parse(response.body)
          json['id'].should == @my_pool.id
          json['access_controls'].should == [{'identity' => @other_identity.short_name, 'access'=>'EDIT'} ]
        end
      end
    end
  end

  describe "create" do
    describe "when not logged on" do
      it "should redirect to home" do
        post :create, :pool=>{:name=>"New Pool"}, identity_id: @identity.short_name
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful when rendering json" do
        post :create, :pool=>{:name=>"New Pool", :short_name=>'new_pool'}, :format=>:json, identity_id: @identity.short_name
        response.should  be_successful
        json = JSON.parse(response.body)
        json['owner_id'].should == @identity.id
        json['name'].should == "New Pool"
        json['short_name'].should == "new_pool"
      end
      it "should give an error when don't have access to that identity" do
        post :create, :pool=>{:name=>"New Pool", :short_name=>'new_pool'}, :format=>:json, identity_id: FactoryGirl.create(:identity).short_name
        response.should be_forbidden
        json = JSON.parse(response.body)
        json['message'].should == "You can't create for that identity"
      end
    end
  end

  describe "update" do
    describe "when not logged on" do
      it "should redirect to home" do
        put :update, :pool=>{:name=>"New Pool"}, identity_id: @identity.short_name, :id=>@my_pool
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        @another_identity = FactoryGirl.create(:identity)
        @another_identity2 = FactoryGirl.create(:identity)
        sign_in @identity.login_credential
      end
      it "should be successful when rendering json" do
        put :update, :pool=>{:name=>"ReName", :short_name=>'updated_pool', 
            :access_controls=>[{identity: @another_identity.short_name, access: 'EDIT'},
                {identity: @another_identity2.short_name, access: 'NONE'}]},
            :format=>:json, identity_id: @identity.short_name, :id=>@my_pool
        response.should  be_successful
        @my_pool.reload
        @my_pool.owner.should == @identity
        @my_pool.name.should == "ReName"
        @my_pool.short_name.should == "updated_pool"
        @my_pool.access_controls.size.should == 1
        @my_pool.access_controls.first.identity.should == @another_identity
        @my_pool.access_controls.first.access.should == "EDIT"
      end
      it "should give an error when don't have access to that identity" do
        put :update, :pool=>{:name=>"New Pool", :short_name=>'new_pool'}, :format=>:json, identity_id: @another_identity.short_name, :id=>@my_pool
        response.should be_not_found
        json = JSON.parse(response.body)
        json['message'].should == "Resource not found"
      end
    end
  end
end
