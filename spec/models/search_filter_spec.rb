require 'spec_helper'

describe SearchFilter do
  it "should persist" do
    exhibit = Exhibit.new
    exhibit.pool = FactoryGirl.create :pool
    exhibit.save
    subject.field_name = "subject"
    subject.operator = "+"
    subject.values = ["foo","bar"]
    subject.filterable   = exhibit
    subject.save
    reloaded = SearchFilter.find(subject.id)
    reloaded.field_name.should == "subject"
    reloaded.operator.should == "+"
    reloaded.values.should == ["foo","bar"]
    reloaded.filterable.should == exhibit
    exhibit.reload.filters.should == [reloaded]
  end
  it "should render solr params" do
    subject.field_name = "subject"
    subject.operator = "+"
    subject.values = ["foo"]
    solr_params, user_params = subject.apply_solr_params({}, {})
    solr_params.should == {fq: ["subject_t:\"foo\""]}
    subject.values = ["bar","baz"]
    solr_params, user_params = subject.apply_solr_params({}, {})
    solr_params.should == {fq: ["subject_t:\"bar\" OR subject_t:\"baz\""]}
  end
  describe "#apply_solr_params_for_filters" do
    before do
      @grant1 = SearchFilter.new(field_name:"collection", operator:"+", values:["birds"])
      @grant2 = SearchFilter.new(field_name:"location", operator:"+", values:["Albuquerque"])
      @restrict1 = SearchFilter.new(field_name:"access_level", operator:"+", values:["public"], filter_type:"RESTRICT")
    end
    it "should combine GRANT filters with OR" do
      solr_params, user_params = SearchFilter.apply_solr_params_for_filters([@grant1, @grant2], {}, {})
      solr_params[:fq].should == ['collection_t:"birds" OR location_t:"Albuquerque"']
    end
    it "should put RESTRICT statements in their own :fq" do
      solr_params, user_params = SearchFilter.apply_solr_params_for_filters([@grant1, @grant2, @restrict1], {}, {})
      solr_params[:fq].should == ['+access_level_t:"public"','collection_t:"birds" OR location_t:"Albuquerque"']
    end
  end
end
