require 'spec_helper'

describe Audience do
  it "has many search filters" do
    subject.search_filters.should == []
    @sf = FactoryGirl.create(:search_filter)
    subject.search_filters << @sf
    subject.search_filters.should == [@sf]
  end
  it "has many members who can belong to many audiences (has and belongs to many)" do
    @identity = FactoryGirl.create(:identity)
    subject.members.should == []
    subject.members << @identity
    subject.members.should == [@identity]
    subject.save
    @identity.audiences.should == [subject]
  end
end
