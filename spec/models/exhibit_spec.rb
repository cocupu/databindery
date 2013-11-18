require 'spec_helper'

describe Exhibit do
  before do
    @identity = FactoryGirl.create :identity
  end
  it "Should have many facets" do
    subject.pool = FactoryGirl.create :pool
    subject.facets = ["Age", "Weight", "Marital status"]
    subject.save!
    subject.reload
    subject.facets.should == ["Age", "Weight", "Marital status"]
  end

  it "should accept_nested_attributes for filters" do
    subject.filters_attributes = [{"field_name"=>"subject", "operator"=>"+", "values"=>["4", "1"]}, {"field_name"=>"collection_owner", "operator"=>"-", "values"=>["Hannah Severin"]}]
    subject.filters.length.should == 2
    subject_filter = subject.filters.select {|f| f.field_name == "subject"}.first
    subject_filter.operator.should == "+"
    subject_filter.values.should == ["4", "1"]
    collection_owner_filter = subject.filters.select {|f| f.field_name == "collection_owner"}.first
    collection_owner_filter.operator.should == "-"
    collection_owner_filter.values.should == ["Hannah Severin"]
  end

  describe "filtering: "  do
    it "should apply filters to solr params logic" do
      # subject.filters = []
      subject.filters << SearchFilter.new(:field_name=>"model", :operator=>"+", :values=>["1","49"])
      subject.filters << SearchFilter.new(:field_name=>"access", :operator=>"+", :values=>["public"])
      subject.filters << SearchFilter.new(:filter_type=>"RESTRICT", :field_name=>"model_name", :operator=>"-", :values=>["song","person"])
      subject.filters << SearchFilter.new(:filter_type=>"RESTRICT", :field_name=>"storage_location", :operator=>"-", :values=>["disk1"])
      solr_params, user_params = subject.apply_solr_params_logic({}, {})
      solr_params.should == {fq: ['-(model_name:"song" OR model_name:"person")', '-storage_location_t:"disk1"', 'model:"1" OR model:"49" OR access_t:"public"']}
    end
  end

  it "should have a title" do
    subject.title = "Persons of note"
    subject.title.should == "Persons of note"
  end

  it "should not be valid unless it has a  pool" do
    subject.should_not be_valid
    subject.pool = Pool.create
    subject.should be_valid
  end
  
end
