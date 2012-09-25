require 'spec_helper'

describe ModelsController do
  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @my_model = FactoryGirl.create(:model, pool: @pool)
    @not_my_model = FactoryGirl.create(:model)
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index }
      it "should show nothing" do
        response.should  be_successful
        assigns[:models].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :index, :identity_id=>@identity.short_name, :pool_id=>@pool.short_name
        response.should  be_successful
        assigns[:models].should == [@my_model]
      end
    end
  end

  describe "show" do
    describe "when not logged on" do
      subject { get :show, :id=>@my_model }
      it "should show nothing" do
        response.should  be_successful
        assigns[:models].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      describe "requesting a model I don't own" do
        it "should redirect to root" do
          get :show, :id=>@not_my_model
          response.should redirect_to root_path
        end
      end
      describe "requesting a model I own" do
        it "should be successful when rendering json" do
          get :show, :id=>@my_model, :format=>:json
          response.should  be_successful
          json = JSON.parse(response.body)
          json['associations'].should == []
          json['fields'].should == [{"name"=>"Description", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"description"}]
        end
      end
    end
  end

  describe "edit" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :edit, :id=>@my_model.id 
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should redirect on a model that's not mine " do
        get :edit, :id=>@not_my_model.id 
        response.should redirect_to root_path
      end
      it "should be successful" do
        get :edit, :id=>@my_model.id 
        response.should be_successful
        assigns[:model].should == @my_model
        assigns[:models].should == [@my_model]
        assigns[:field].should == {name: '', type: '', uri: '', multivalued: false}.stringify_keys
        assigns[:association].should == {name: '', type: '', references: ''}.stringify_keys
        assigns[:association_types].should == ['Has Many', 'Has One', 'Ordered List', 'Unordered List']
        assigns[:field_types].should == [["Text Field", "text"], ["Text Area", "textarea"], ["Date", "date"]]
      end
    end
  end

  describe "new" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :new
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :new
        response.should be_successful
        assigns[:model].should be_kind_of Model
      end
    end
  end
  describe "create" do
    describe "when not logged on" do
      it "should redirect to root" do
        post :create, :pool_id=>@identity.pools.first.id, identity_id: @identity.short_name
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should render the form when validation fails" do
        post :create, :model=>{:foo=>'bar'}, :pool_id=>@identity.pools.first.id, identity_id: @identity.short_name
        response.should be_successful
        response.should render_template(:new)
        assigns[:model].should be_kind_of Model
      end
      it "should be successful" do
        post :create, :model=>{:name=>'Turkey'}, :pool_id=>@identity.pools.first.id, identity_id: @identity.short_name
        response.should redirect_to edit_model_path(assigns[:model])
        assigns[:model].should be_kind_of Model
        assigns[:model].name.should == 'Turkey'
      end
      it "should be successful with json" do
        in_pool = FactoryGirl.create(:pool, owner: @identity)
        post :create, :model=>{:name=>'Turkey'}, :pool_id=>in_pool.id, :format=>:json, identity_id: @identity.short_name
        response.should be_successful
        json = JSON.parse response.body
        json["name"].should == 'Turkey'
        json["pool_id"].should == in_pool.id
        json["id"].should_not be_nil
      end
      it "should not allow you to create models in someone elses pool" do
        in_pool = FactoryGirl.create(:pool)
        post :create, :model=>{:name=>'Turkey'}, :pool_id=>in_pool.id, :format=>:json, identity_id: @identity.short_name
        response.response_code.should == 403
      end
      it "should not allow you to create models with someone elses identity" do
        in_pool = FactoryGirl.create(:pool, owner: @identity)
        post :create, :model=>{:name=>'Turkey'}, :pool_id=>in_pool.id, :format=>:json, identity_id: FactoryGirl.create(:identity)
        response.should be_forbidden
        json = JSON.parse(response.body)
        json['message'].should == "You can't create for that identity"
      end
    end
  end

  describe "update" do
    describe "when not logged on" do
      it "should redirect to root" do
        put :update, :id=>@my_model, :model=>{:label=>'title'}
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should redirect on a model that's not mine " do
        put :update, :id=>@not_my_model, :model=>{:label=>'title'}
        response.should redirect_to root_path
        flash[:alert].should == "You are not authorized to access this page."
      end

      it "should be able to set the identifier" do
        put :update, :id=>@my_model, :model=>{:label=>'description'}

        response.should redirect_to edit_model_path(@my_model)
        flash[:notice].should == "#{@my_model.name} has been updated"
        @my_model.reload.label.should == 'description'
      end
      it "should be able to set the identifier via json" do
        put :update, :id=>@my_model, :model=>{:label=>'description'}, :format=>:json
        response.should be_successful 
        @my_model.reload.label.should == 'description'
      end
    end
  end

end
