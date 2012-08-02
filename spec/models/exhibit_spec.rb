require 'spec_helper'

describe Exhibit do
  it "Should have many facets" do
    subject.pool = FactoryGirl.create :pool
    subject.facets = ["Age", "Weight", "Marital status"]
    subject.save!
    subject.reload
    subject.facets.should == ["Age", "Weight", "Marital status"]
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
