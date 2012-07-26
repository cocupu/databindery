require 'spec_helper'

describe LoginCredential do
  describe "after save" do
    before do
      build = FactoryGirl.build :login
      subject.update_attributes(:email=>build.email, :password=>build.password)
      subject.save!
    end
    it "should have at least one identity" do
      subject.identities.size.should == 1
    end
  end
end
