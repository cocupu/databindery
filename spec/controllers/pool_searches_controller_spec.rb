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
    end
    describe "json query API" do
      before do
        sign_in @identity.login_credential
        @other_pool = FactoryGirl.create(:pool, owner: @identity)
        @auto_model = FactoryGirl.create(:model, pool: @other_pool, name:"/automotive/model")
        @auto_model.fields << {"code"=>"name", "name"=>"Name"}.with_indifferent_access
        @auto_model.fields << {"code"=>"year", "name"=>"Year"}.with_indifferent_access
        @auto_model.fields << {"code"=>"make", "name"=>"Make", "uri"=>"/automotive/model/make"}.with_indifferent_access
        @auto_model.label = "name"
        @auto_model.save
        AccessControl.create!(:pool=>@other_pool, :identity=>@identity, :access=>'READ')
        @node1 = Node.create!(model:@auto_model, pool: @other_pool, data:{"year"=>"2009", "make"=>"/en/ford", "name"=>"Ford Taurus"})
        @node2 = Node.create!(model:@auto_model, pool: @other_pool, data:{"year"=>"2011", "make"=>"/en/ford", "name"=>"Ford Taurus"})
        @node3 = Node.create!(model:@auto_model, pool: @other_pool, data:{"year"=>"2013", "make"=>"barf", "name"=>"Puke"})
        @node4 = Node.create!(model:@auto_model, pool: @other_pool, data:{"year"=>"2012", "make"=>"barf", "name"=>"Upchuck"})
      end
      it "should be successful when rendering json" do
        get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name
        response.should  be_successful
        json = JSON.parse(response.body)
        pids = json.map {|doc| doc["id"]}
        [@node1, @node2, @node3, @node4].each {|n| pids.should include(n.persistent_id)}
      end
      it "should support queries using Google Refine Reconciliation API multi-query mode" do
        q1_params = {
            "query" => "Ford Taurus",
            "limit" => 3,
            "type" => "/automotive/model",
            "type_strict" => "any",
            "properties" => [
                { "p" => "year", "v" => 2009 },
                { "pid" => "/automotive/model/make" , "v" => "/en/ford" }
            ]
        }
        get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, queries: {"q1" => q1_params, "blargq"=>{"query"=>"barf"}}
        json = JSON.parse(response.body)
        # Scores change depending on what's in solr, so pulling them out of the JSON and just validating that they are floats.
        json["q1"]["result"].each {|r| r.delete("score").should be_instance_of(Float) }
        json["blargq"]["result"].each {|r| r.delete("score").should be_instance_of(Float) }
        # Validate the rest of the json results with scores removed
        json["q1"].should == {"result" => [{"id"=>@node1.persistent_id, "name"=>@node1.title, "type"=>["/automotive/model"], "match"=>true }]}
        json["blargq"].should == {"result" => [{"id"=>@node3.persistent_id, "name"=>@node3.title, "type"=>["/automotive/model"], "match"=>true },{"id"=>@node4.persistent_id, "name"=>@node4.title, "type"=>["/automotive/model"], "match"=>true }]}
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