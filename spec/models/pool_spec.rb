require 'spec_helper'

describe Pool do
  it "should belong to an identity" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end
end
