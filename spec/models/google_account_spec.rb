require 'spec_helper'

describe GoogleAccount do
  it "should have an owner" do
    ident = Identity.create
    subject.owner = ident
    subject.owner.should == ident

  end
end
