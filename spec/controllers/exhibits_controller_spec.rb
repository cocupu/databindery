require 'spec_helper'

describe ExhibitsController do
  it "should route" do
    exhibits_path.should == '/exhibits'
  end

  describe "index" do
    it "should be success" do
      get :index
      response.should be_successful
    end
  end

  describe "search" do
    before do
      ## Clear out old results so we start from scratch
      raw_results = Cocupu.solr.get 'select', :params => {:q => 'bazaar', :fl=>'id', :qf=>'field_good_s'}
      Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
      Cocupu.solr.commit
      @model = Model.create(:name=>"Mods and Rockers")
      f1 = Field.new(:label=>'Field good')
      @model.m_fields << f1

      @instance = ModelInstance.new(:model=>@model)
      @instance.save
      @instance.properties << Property.new(:value=>"bazaar", :field=>f1) 
      @model.index
    end
    it "should be success" do
      get :index, :q=>'bazaar'
      assigns[:total].should == 1
      assigns[:results].should_not be_nil
      response.should be_successful
    end
  end


end
