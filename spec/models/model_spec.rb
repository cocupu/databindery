require 'spec_helper'

describe Model do
  it "should have many fields" do
    subject.fields = {'one' => 'One'}
    subject.fields['two'] = 'Two'
    subject.fields['one'].should == "One"
  end

  it "should have a label" do
    subject.label = "title"
    subject.label.should == "title"
  end
end
