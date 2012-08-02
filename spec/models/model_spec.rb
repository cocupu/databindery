require 'spec_helper'

describe Model do
  before do
    subject.name = "Test Name"
  end

  it "should have many fields" do
    subject.fields = {'one' => 'One'}
    subject.fields['two'] = 'Two'
    subject.fields['one'].should == "One"
  end

  it "should have a label" do
    subject.label = "title"
    subject.label.should == "title"
  end

  it "should belong to an identity" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end
end
