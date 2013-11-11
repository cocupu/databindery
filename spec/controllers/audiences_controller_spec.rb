require 'spec_helper'

describe AudiencesController do
  before do
    @identity = FactoryGirl.create :identity
    @another_identity = FactoryGirl.create(:identity)
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @category = FactoryGirl.create :audience_category, :pool=>@pool
    @audience = FactoryGirl.create :audience, :audience_category=>@category
    @pool.audience_categories <<  @category
    @not_my_pool = FactoryGirl.create :pool, owner: @another_identity
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category }
      it "should show nothing" do
        response.should  be_successful
        assigns[:audiences].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :index, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category, format: :json
        response.should  be_successful
        assigns[:audiences].should == [@audience]
      end
      it "should return json" do
        get :index, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category, format: :json
        response.should be_successful
        json = JSON.parse(response.body)
        json.first.delete("created_at")
        json.first.delete("updated_at")
        json.should == [{"audience_category_id"=>@category.id, "description"=>"MyText", "id"=>@audience.id, "name"=>"MyString", "position"=>nil, "filters"=>[], "member_ids"=>[],  "pool_name"=>@pool.short_name, "identity_name"=>@identity.short_name}]
      end
    end
  end

  describe "show" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :show, id: @audience, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
        @not_my_category = FactoryGirl.create :audience_category, pool:@not_my_pool
        @not_my_audience = FactoryGirl.create :audience, audience_category:@not_my_category
      end
      describe "requesting an audience in a pool I don't control" do
        it "should redirect to root" do
          get :show, :id=>@not_my_audience, identity_id: @identity.short_name, pool_id: @not_my_pool.short_name, audience_category_id:@not_my_category, format: :json
          response.should be_forbidden
        end
      end
      describe "requesting audiences from a pool I own" do
        it "should be successful when rendering json" do
          get :show, :id=>@audience, identity_id: @identity.short_name, pool_id: @pool, audience_category_id:@category, format: :json
          response.should  be_successful
          json = JSON.parse(response.body)
          json.delete("created_at")
          json.delete("updated_at")
          json.should == {"audience_category_id"=>@category.id, "description"=>"MyText", "id"=>@audience.id, "name"=>"MyString", "position"=>nil, "filters"=>[], "member_ids"=>[],  "pool_name"=>@pool.short_name, "identity_name"=>@identity.short_name}
        end
      end
    end
  end

  describe "create" do
    describe "when not logged on" do
      it "should redirect to home" do
        post :create, :audience=>{:name=>"New Audience"}, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful when rendering json" do
        post :create, :audience=>{:name=>"New Audience", description:"A Description"}, :format=>:json, identity_id: @identity.short_name, pool_id: @pool.short_name, audience_category_id:@category
        response.should  be_successful
        json = JSON.parse(response.body)
        json["audience_category_id"].should == @category.id
        json['name'].should == "New Audience"
        json['description'].should == "A Description"
      end
    end
  end

  describe "update" do
    describe "when not logged on" do
      it "should redirect to home" do
        put :update, :audience=>{:name=>"New Audience"}, identity_id: @identity.short_name, :id=>@audience, pool_id: @pool.short_name, audience_category_id:@category
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        @another_identity2 = FactoryGirl.create(:identity)
        sign_in @identity.login_credential
        @not_my_category = FactoryGirl.create :audience_category, :pool=>@not_my_pool
        @not_my_audience = FactoryGirl.create :audience, audience_category:@not_my_category
      end
      it "should be successful when rendering json" do
        put :update, :audience=>{name: "ReName", description:"New Description"},
            :format=>:json, identity_id: @identity.short_name, :id=>@audience, pool_id:@pool.short_name, audience_category_id:@category
        response.should  be_successful
        @audience.reload
        @audience.name.should == "ReName"
        @audience.description.should == "New Description"
      end
      it "should allow you to update audiences from a json property called audiences (not audiences_attributes)" do
        put :update, audience:{"description"=>"New description", "id"=>@audience.id, "name"=>"The Category", "filters"=>[{"field_name"=>"title"}, {"field_name"=>"date_created"}, {"field_name"=>"date_updated"}]},
            :format=>:json, identity_id: @identity.short_name, :id=>@audience, pool_id:@pool.short_name, audience_category_id:@category
        response.should  be_successful
        @audience.reload
        @audience.description.should == "New description"
        @audience.name.should == "The Category"
        @audience.filters.count.should == 3
        other_filter = @audience.filters.where(field_name: "date_created").first
        put :update, audience:{"filters"=>[{"id"=>other_filter.id, "_destroy"=>"1"}]},
            :format=>:json, identity_id: @identity.short_name, :id=>@audience, pool_id:@pool.short_name, audience_category_id:@category
        @audience.reload
        @audience.filters.count.should == 2
        @audience.filters.where(field_name: "date_created").should be_empty
      end
      it "should give an error when don't have edit powers on the category (or its pool)" do
        put :update, :audience=>{:name=>"Rename"}, :format=>:json, identity_id: @another_identity.short_name, :id=>@not_my_audience, pool_id: @pool.short_name, audience_category_id:@not_my_category
        json = JSON.parse(response.body)
        json['message'].should == "You are not authorized to access this page."
      end
    end
  end
end
