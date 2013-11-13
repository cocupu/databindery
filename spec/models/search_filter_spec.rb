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
    solr_params.should == {fq: ["+subject_t:\"foo\""]}
    subject.values = ["bar","baz"]
    solr_params, user_params = subject.apply_solr_params({}, {})
    solr_params.should == {fq: ["subject_t:\"bar\" OR subject_t:\"baz\""]}
  end
  it "should allow manipulation of filter values array via values_tokens" do
    subject.values.should == []
    subject.values_tokens = "foo;;bar;;And then, because values often include free text, they chose to use two semicolons as the delimiter."
    subject.values.should == ["foo","bar","And then, because values often include free text, they chose to use two semicolons as the delimiter."]
    subject.values << "Another Value"
    subject.values_tokens.should  == "foo;;bar;;And then, because values often include free text, they chose to use two semicolons as the delimiter.;;Another Value"
  end
end
