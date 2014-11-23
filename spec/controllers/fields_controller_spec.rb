require 'spec_helper'

describe FieldsController do
  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @my_model = FactoryGirl.create(:model, pool: @pool)
    @not_my_model = FactoryGirl.create(:model)
  end
  describe "create" do
    describe "when not logged on" do
      it "should redirect to root" do
        post :create, :model_id=>@my_model.id 
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should redirect on a model that's not mine " do
        post :create, :model_id=>@not_my_model.id 
        response.should redirect_to root_path
      end
      it "should create and redirect" do
        post :create, :model_id=>@my_model.id, :field=>{name: 'Event Date', type: 'DateField', uri: 'dc:date', multivalue: true}
        @my_model.reload
        @my_model.fields.count.should == 2
        @my_model.fields.first.code.should == "description"
        new_field = @my_model.fields.last
        new_field.code.should == "event_date"
        new_field.name.should == "Event Date"
        new_field.type.should == "DateField"
        new_field.uri.should == "dc:date"
        new_field.multivalue.should == true
        response.should redirect_to edit_model_path(@my_model)
      end
      it "should be successful with json" do
        post :create, :model_id=>@my_model.id, :field=>{name: 'Event Date', type: 'DateField', uri: 'dc:date', multivalue: true}, :format=>:json
        @my_model.reload
        @my_model.fields.count.should == 2
        @my_model.fields.first.code.should == "description"
        new_field = @my_model.fields.last
        new_field.code.should == "event_date"
        new_field.name.should == "Event Date"
        new_field.type.should == "DateField"
        new_field.uri.should == "dc:date"
        new_field.multivalue.should == true
        response.should be_successful
      end
    end
  end

  describe "index" do
    describe "when not logged on" do
      it "should redirect to home" do
        get :index, identity_id: @identity.short_name, :pool_id=>@pool
        response.should redirect_to(root_path)
      end
    end
    describe "when I cannot edit the pool" do
      before do
        @another_identity = FactoryGirl.create(:identity)
        sign_in @another_identity.login_credential
      end
      it "should redirect to home" do
        get :index, identity_id: @identity.short_name, :pool_id=>@pool
        response.should redirect_to(root_path)
      end
    end
    describe "when I can edit the pool" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful when rendering json" do
        get :index, identity_id: @identity.short_name, :pool_id=>@pool, format: :json
        response.should be_successful
        assigns[:fields].should == @pool.all_fields
        json = JSON.parse(response.body)
        json.should == JSON.parse(@pool.all_fields.to_json)
      end
    end
  end

  describe "show" do
    before do
      @field = Field.create(:code=>'title', :name=>'Title', :type=>'TextField', :uri=>'dc:name', :multivalue=>true)
      @my_model.fields << @field
      @my_model.save
    end
    describe "when not logged on" do
      it "should redirect to home" do
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field.code
        response.should redirect_to(root_path)
      end
    end
    describe "when I cannot edit the pool" do
      before do
        @another_identity = FactoryGirl.create(:identity)
        sign_in @another_identity.login_credential
      end
      it "should redirect to home" do
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field.code
        response.should redirect_to(root_path)
      end
    end
    describe "when I can edit the pool" do
      before do
        sign_in @identity.login_credential
      end
      it "should return field info and current values from pool" do
        FactoryGirl.create(:node, pool:@pool, model:@my_model, data:{@field.id.to_s=>"My title"})
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field.code, format: :json
        response.should be_successful
        assigns[:field].should == @field
        json = JSON.parse(response.body)
        json.should == JSON.parse(@field.as_json.merge("numDocs"=>1, "values"=>[{"value"=>"My title", "count"=>1}]).to_json)
      end
    end
  end
end