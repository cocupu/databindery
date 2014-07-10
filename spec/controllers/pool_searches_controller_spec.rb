require 'spec_helper'

describe PoolSearchesController do
  before do
    @identity = FactoryGirl.create :identity
    @my_pool = FactoryGirl.create :pool, :owner=>@identity
    @not_my_pool = FactoryGirl.create(:pool, owner: FactoryGirl.create(:identity))
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
      describe "requesting a pool I don't have access to" do
        it "should redirect to root" do
          get :index, :pool_id=>@not_my_pool.short_name, identity_id: @not_my_pool.owner.short_name
          response.should redirect_to( root_path )
        end
      end
      describe "requesting a pool I have read access for" do
        it "should be successful" do
          AccessControl.create!(:pool=>@other_pool, :identity=>@identity, :access=>'READ')
          get :index, :pool_id=>@other_pool, identity_id: @identity.short_name
          response.should be_success
        end
        describe "grid view" do
          it "should filter to one model" do
            get :index, :pool_id=>@other_pool, identity_id: @identity.short_name, view:"grid"
            subject.solr_search_params[:fq].should include("model:#{@other_pool.models.first.id}")
          end
          it "should support choosing model" do
            get :index, :pool_id=>@other_pool, identity_id: @identity.short_name, model_id: @my_model_different_pool.id, view:"grid"
            subject.solr_search_params[:fq].should include("model:#{@my_model_different_pool.id}")
          end
        end
      end
      describe "requesting a pool I own" do
        it "should be successful" do
          get :index, :pool_id=>@my_pool, identity_id: @identity.short_name
          response.should be_success
        end
        it "should apply filters and facets from exhibit" do
          exhibit_with_filters = FactoryGirl.build(:exhibit, pool: @my_pool, filters_attributes: [field_name:"subject", operator:"+", values:["test", "barf"]])
          exhibit_with_filters.save!
          get :index, :pool_id=>@my_pool, :perspective=>exhibit_with_filters.id, identity_id: @identity.short_name
          subject.exhibit.should == exhibit_with_filters
          subject.solr_search_params[:fq].should include('subject_s:"test" OR subject_s:"barf"')
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
      it "should provide blacklight-ish json response by default" do
        get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name
        response.should  be_successful
        json = JSON.parse(response.body)
        json["responseHeader"]["params"].keys.should include{"facet"}
        json["responseHeader"]["params"].keys.should include{"rows"}
        json["response"]["numFound"].should == 4
        pids = json["docs"].map {|doc| doc["id"]}
        [@node1, @node2, @node3, @node4].each {|n| pids.should include(n.persistent_id)}
      end
      it "should support nodesOnly json responses" do
        get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, "nodesOnly"=>"true"
        response.should  be_successful
        json = JSON.parse(response.body)
        pids = json.map {|doc| doc["id"]}
        [@node1, @node2, @node3, @node4].each {|n| pids.should include(n.persistent_id)}
      end
      it "should allow faceted queries" do
        get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, "nodesOnly"=>"true", "f" => {Node.solr_name("make", type: "facet") => "barf"}
        response.should  be_successful
        json = JSON.parse(response.body)
        pids = json.map {|doc| doc["id"]}
        [@node3, @node4].each {|n| pids.should include(n.persistent_id)}
        [@node1, @node2].each {|n| pids.should_not include(n.persistent_id)}
      end
      describe "Google Refine Reconciliation API multi-query mode" do
        before do
          @q1_params = {
              "query" => "Ford Taurus",
              "limit" => 3,
              "type" => "/automotive/model",
              "type_strict" => "any",
              "properties" => [
                  { "p" => "year", "v" => 2009 },
                  { "pid" => "/automotive/model/make" , "v" => "/en/ford" }
              ]
          }
        end
        it "should support queries using Google Refine Reconciliation API multi-query mode" do
          get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, queries: {"q1" => @q1_params, "blargq"=>{"query"=>"barf"}}
          json = JSON.parse(response.body)
          # Scores change depending on what's in solr, so pulling them out of the JSON and just validating that they are floats.
          json["q1"]["result"].each {|r| r.delete("score").should be_instance_of(Float) }
          json["blargq"]["result"].each {|r| r.delete("score").should be_instance_of(Float) }
          # Validate the rest of the json results with scores removed
          json["q1"]["result"].should == [{"id"=>@node1.persistent_id, "name"=>@node1.title, "type"=>["/automotive/model"], "match"=>true }]
          json["q1"]["maxScore"].should_not be_nil
          json["q1"]["start"].should == 0
          json["q1"]["numFound"].should == 1
          json["blargq"]["result"].should == [{"id"=>@node3.persistent_id, "name"=>@node3.title, "type"=>["/automotive/model"], "match"=>true },{"id"=>@node4.persistent_id, "name"=>@node4.title, "type"=>["/automotive/model"], "match"=>true }]
          json["blargq"]["maxScore"].should_not be_nil
          json["blargq"]["start"].should == 0
          json["blargq"]["numFound"].should == 2
        end
        it "should support query by model_id" do
          other_model = FactoryGirl.create(:model, pool: @other_pool)
          non_car = Node.create!(model:other_model, pool: @other_pool, data:{"year"=>"2012", "make"=>"barf", "name"=>"Upchuck"})
          get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, queries: {"modelq"=>{"properties"=>["p"=>"model_id", "v"=>other_model.id]}}
          json = JSON.parse(response.body)
          json["modelq"]["result"].count.should == 1
          json["modelq"]["result"].first["id"].should == non_car.persistent_id
        end
        it "should return full json representations of nodes when requested" do
          get :index, :pool_id=>@other_pool, :format=>:json, identity_id: @identity.short_name, marshall_nodes:true, queries: {"q1" => @q1_params, "blargq"=>{"query"=>"barf"}}
          json = JSON.parse(response.body)
          all_results = json["q1"]["result"].concat(json["blargq"]["result"])
          all_results.each do |r|
            r["data"].should be_kind_of Hash
            r["associations"].should be_kind_of Hash
            r["title"].should be_kind_of String
          end
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
  
  describe "overview" do
    describe "when not logged on" do
      it "should redirect to root" do
        get :overview, pool_id: @my_pool, identity_id: @identity.short_name
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
          get :overview, :pool_id=>@not_my_pool, identity_id: @identity.short_name
          response.should be_not_found
        end
      end
      describe "requesting a pool I own" do
        it "should be successful" do
          get :overview, :pool_id=>@my_pool, identity_id: @identity.short_name, :format=>:json
          redirect_to( identity_pool_search_path(@identity.short_name, @my_pool.id) )
        end
      end
      describe "requesting a pool I can edit" do
        before do
          @other_identity = FactoryGirl.create(:identity)
          AccessControl.create!(:pool=>@my_pool, :identity=>@other_identity, :access=>'EDIT')
        end
        it "should be successful when rendering json" do
          get :overview, :pool_id=>@my_pool, :format=>:json, identity_id: @identity.short_name
          response.should  be_successful
          json = JSON.parse(response.body)
          json['id'].should == @my_pool.id
          json['models'].should == JSON.parse(@my_pool.models.to_json)
          json['perspectives'].should == @my_pool.exhibits.as_json
          json['facets'].should == {"model_name"=>[], "description_facet"=>[]}
          json["numFound"].should == 0
        end
      end
    end
  end
  
end