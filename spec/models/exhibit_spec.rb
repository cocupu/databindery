require 'spec_helper'

describe Exhibit do
  before do
    @exhibit = Exhibit.new
  end
  it "Should have many facets" do
    @exhibit.facets = ["Age", "Weight", "Marital status"].map{|f| Exhibit::Facet.new(:value=>f)}
    @exhibit.facets.map(&:value).should == ["Age", "Weight", "Marital status"]
  end

  it "should have a title" do
    @exhibit.title = "Persons of note"
    @exhibit.title.should == "Persons of note"
  end
end