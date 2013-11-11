require 'spec_helper'

describe AudienceCategoriesController do
  before do
    @identity = FactoryGirl.create :identity
    @another_identity = FactoryGirl.create(:identity)
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @category = FactoryGirl.create :audience_category, :pool=>@pool
    @pool.audience_categories <<  @category
    @not_my_pool = FactoryGirl.create :pool, owner: @another_identity
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index, identity_id: @identity.short_name, pool_id: @pool.short_name }
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
        get :index, identity_id: @identity.short_name, pool_id: @pool.short_name, format: :json
        response.should  be_successful
        assigns[:audience_categories].should == [@category]
      end
      it "should return json" do
        get :index, identity_id: @identity.short_name, pool_id: @pool.short_name, format: :json
        response.should be_successful
        json = JSON.parse(response.body)
        json.first.delete("created_at")
        json.first.delete("updated_at")
        json.should == [{"description"=>"MyText", "id"=>@category.id, "name"=>"MyString", "pool_id"=>@pool.id, "audiences"=>[]}]
      end
    end
  end

  describe "show" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :show, id: @category, identity_id: @identity.short_name, pool_id: @pool.short_name
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
        @not_my_category = FactoryGirl.create :audience_category, :pool=>@not_my_pool
      end
      describe "requesting a pool I don't own" do
        it "should redirect to root" do
          get :show, :id=>@not_my_category, identity_id: @identity.short_name, pool_id: @not_my_pool.short_name, format: :json
          response.should be_forbidden
        end
      end
      describe "requesting audience categories from a pool I own" do
        it "should be successful when rendering json" do
          get :show, :id=>@category, identity_id: @identity.short_name, pool_id: @pool, format: :json
          response.should  be_successful
          json = JSON.parse(response.body)
          json.delete("created_at")
          json.delete("updated_at")
          json.should == {"description"=>"MyText", "id"=>@category.id, "name"=>"MyString", "pool_id"=>@pool.id, "audiences"=>[]}
        end
      end
    end
  end

  describe "create" do
    describe "when not logged on" do
      it "should redirect to home" do
        post :create, :audience_category=>{:name=>"New Category"}, identity_id: @identity.short_name, pool_id: @pool.short_name
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful when rendering json" do
        post :create, :audience_category=>{:name=>"New Category", description:"A Description"}, :format=>:json, identity_id: @identity.short_name, pool_id: @pool.short_name
        response.should  be_successful
        json = JSON.parse(response.body)
        json["pool_id"].should == @pool.id
        json['name'].should == "New Category"
        json['description'].should == "A Description"
      end
    end
  end

  describe "update" do
    describe "when not logged on" do
      it "should redirect to home" do
        put :update, :audience_category=>{:name=>"New Category"}, identity_id: @identity.short_name, :id=>@category, pool_id: @pool.short_name
        response.should redirect_to(root_path)
      end
    end

    describe "when logged on" do
      before do
        @another_identity2 = FactoryGirl.create(:identity)
        sign_in @identity.login_credential
        @not_my_category = FactoryGirl.create :audience_category, :pool=>@not_my_pool
      end
      it "should be successful when rendering json" do
        put :update, :audience_category=>{name: "ReName", description:"New Description"},
            :format=>:json, identity_id: @identity.short_name, :id=>@category, pool_id:@pool.short_name
        response.should  be_successful
        @category.reload
        @category.name.should == "ReName"
        @category.description.should == "New Description"
      end
      it "should allow you to update audiences from a json property called audiences (not audiences_attributes)" do
        put :update, audience_category:{"description"=>"New description", "id"=>@category.id, "name"=>"The Category", "audiences"=>[{"description"=>nil, "name"=>"Level One", "position"=>nil}, {"description"=>nil, "name"=>"Level Two", "position"=>nil}, {"name"=>"Other Level"}]},
            :format=>:json, identity_id: @identity.short_name, :id=>@category, pool_id:@pool.short_name
        response.should  be_successful
        @category.reload
        @category.description.should == "New description"
        @category.name.should == "The Category"
        @category.audiences.count.should == 3
        other_audience = @category.audiences.where(name: "Other Level").first
        put :update, audience_category:{"audiences"=>[{"id"=>other_audience.id, "_destroy"=>"1"}]},
            :format=>:json, identity_id: @identity.short_name, :id=>@category, pool_id:@pool.short_name
        @category.reload
        @category.audiences.count.should == 2
        @category.audiences.where(name: "Other Level").should be_empty
      end
      #it "should support submission of json" do
      #  # when submitting json pool info, access_controls isn't being copied into params[:pool].
      #  # This test makes sure that the controller handles that case.
      #  put :update, :access_controls=>[{identity: @another_identity.short_name, access: 'EDIT'},
      #                                  {identity: @another_identity2.short_name, access: 'NONE'}],
      #      pool: {:name=>"ReName", :short_name=>'updated_pool'},
      #      :format=>:json, identity_id: @identity.short_name, :id=>@pool
      #  response.should  be_successful
      #  @pool.reload
      #  @pool.owner.should == @identity
      #  @pool.name.should == "ReName"
      #  @pool.short_name.should == "updated_pool"
      #  @pool.access_controls.size.should == 1
      #  @pool.access_controls.first.identity.should == @another_identity
      #  @pool.access_controls.first.access.should == "EDIT"
      #end
      it "should give an error when don't have edit powers on the category (or its pool)" do
        put :update, :audience_category=>{:name=>"Rename"}, :format=>:json, identity_id: @another_identity.short_name, :id=>@not_my_category, pool_id: @pool.short_name
        json = JSON.parse(response.body)
        json['message'].should == "You are not authorized to access this page."
      end
    end
  end
end
