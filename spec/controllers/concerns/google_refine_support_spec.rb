require 'spec_helper'

describe PoolSearchesController do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool) { FactoryGirl.create :pool, owner:identity }
  let(:name_field) { FactoryGirl.create(:field, code:"name", name:"Name") }
  let(:year_field) { FactoryGirl.create(:field, code:"year", name:"Year") }
  let(:make_field) { FactoryGirl.create(:field, code:"make", name:"Make", uri:"/automotive/model/make") }
  let(:auto_model) { FactoryGirl.create(:model, pool: pool, name:"/automotive/model", label_field: name_field, fields: [name_field, year_field, make_field]) }

  describe "Google Refine Reconciliation API multi-query mode" do
    before do
      sign_in identity.login_credential
      AccessControl.create!(:pool=>pool, :identity=>identity, :access=>'READ')
      @node1 = Node.create!(model:auto_model, pool: pool, data:auto_model.convert_data_field_codes_to_id_strings("year"=>"2009", "make"=>"/en/ford", "name"=>"Ford Taurus"))
      @node2 = Node.create!(model:auto_model, pool: pool, data:auto_model.convert_data_field_codes_to_id_strings("year"=>"2011", "make"=>"/en/ford", "name"=>"Ford Taurus"))
      @node3 = Node.create!(model:auto_model, pool: pool, data:auto_model.convert_data_field_codes_to_id_strings("year"=>"2013", "make"=>"barf", "name"=>"Puke"))
      @node4 = Node.create!(model:auto_model, pool: pool, data:auto_model.convert_data_field_codes_to_id_strings("year"=>"2012", "make"=>"barf", "name"=>"Upchuck"))
    end
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
      get :index, :pool_id=>pool, :format=>:json, identity_id: identity.short_name, queries: {"q1" => @q1_params, "blargq"=>{"query"=>"barf"}}
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
      other_model = FactoryGirl.create(:model, pool: pool)
      non_car = Node.create!(model:other_model, pool: pool, data:{"year"=>"2012", "make"=>"barf", "name"=>"Upchuck"})
      get :index, :pool_id=>pool, :format=>:json, identity_id: identity.short_name, queries: {"modelq"=>{"properties"=>["p"=>"model_id", "v"=>other_model.id]}}
      json = JSON.parse(response.body)
      json["modelq"]["result"].count.should == 1
      json["modelq"]["result"].first["id"].should == non_car.persistent_id
    end
    it "should return full json representations of nodes when requested" do
      get :index, :pool_id=>pool, :format=>:json, identity_id: identity.short_name, marshall_nodes:true, queries: {"q1" => @q1_params, "blargq"=>{"query"=>"barf"}}
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