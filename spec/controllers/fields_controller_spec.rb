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
        post :create, :model_id=>@my_model.id, :field=>{name: 'Event Date', type: 'Date', uri: 'dc:date', multivalued: true}
        @my_model.reload.fields.should == 
           [{"name"=>"Description", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"description"}, {"name" => 'Event Date', "code"=>"event_date", "type" => 'Date', "uri" => 'dc:date', "multivalued" => true}]
        response.should redirect_to edit_model_path(@my_model)
      end
      it "should be successful with json" do
        post :create, :model_id=>@my_model.id, :field=>{name: 'Event Date', type: 'Date', uri: 'dc:date', multivalued: true}, :format=>:json
        @my_model.reload.fields.should == 
           [{"name"=>"Description", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"description"}, {"name" => 'Event Date', "code"=>"event_date", "type" => 'Date', "uri" => 'dc:date', "multivalued" => true}]
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
        json.should == @pool.all_fields.as_json
      end
    end
  end

  describe "show" do
    before do
      @my_model.fields << {:code=>'title', :name=>'Title', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
      @my_model.save
      @field = @my_model.fields.select {|f| f[:code] == "title"}.first
    end
    describe "when not logged on" do
      it "should redirect to home" do
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field["code"]
        response.should redirect_to(root_path)
      end
    end
    describe "when I cannot edit the pool" do
      before do
        @another_identity = FactoryGirl.create(:identity)
        sign_in @another_identity.login_credential
      end
      it "should redirect to home" do
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field["code"]
        response.should redirect_to(root_path)
      end
    end
    describe "when I can edit the pool" do
      before do
        sign_in @identity.login_credential
      end
      it "should return field info and current values from pool" do
        node = FactoryGirl.create(:node, pool:@pool, model:@my_model, data:{"title"=>"My title"})
        get :show, identity_id: @identity.short_name, :pool_id=>@pool, id:@field["code"], format: :json
        response.should be_successful
        assigns[:field].should == @field
        json = JSON.parse(response.body)
        json.should == @field.as_json.merge("numDocs"=>1, "values"=>[{"value"=>"My title", "count"=>1}])
      end
    end
  end
end