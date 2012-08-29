require 'spec_helper'

describe ModelsController do
  before do
    @user = FactoryGirl.create :login
    @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
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
        sign_in @user
      end
      it "should be successful" do
        get :index 
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
        sign_in @user
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
        sign_in @user
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
        sign_in @user
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
        post :create
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @user
      end
      it "should redirect to form when validation fails" do
        post :create, :model=>{}
        response.should be_successful
        response.should render_template(:new)
        assigns[:model].should be_kind_of Model
      end
      it "should be successful" do
        post :create, :model=>{:name=>'Turkey'}
        response.should redirect_to edit_model_path(assigns[:model])
        assigns[:model].should be_kind_of Model
        assigns[:model].name.should == 'Turkey'
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
        sign_in @user
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
