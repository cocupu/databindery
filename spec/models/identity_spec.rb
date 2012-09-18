require 'spec_helper'

describe Identity do
  describe "short_name" do
    it "should be required" do
      subject.valid?.should be_false
      subject.short_name = "foo"
      subject.valid?.should be_true
    end

    it "should force lowercase" do
      subject.short_name = "FOO"
      subject.short_name.should == 'foo'
    end
  end
  describe "after save" do
    before do
      subject.short_name="foo"
      subject.save!
    end
    it "should have many google accounts" do
      subject.google_accounts.should == []
      @ga = GoogleAccount.new
      subject.google_accounts << @ga
      subject.google_accounts.should == [@ga]
      
    end
  end
  
end
