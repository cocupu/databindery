require 'spec_helper'

describe Identity do
  describe "after save" do
    before do
      subject.login_credential= FactoryGirl.create(:login)
      subject.save!
    end
    it "should have at least one pool" do
      subject.pools.size.should == 1
    end
    it "should have many google accounts" do
      subject.google_accounts.should == []
      @ga = GoogleAccount.new
      subject.google_accounts << @ga
      subject.google_accounts.should == [@ga]
      
    end
  end
  
end
