require 'spec_helper'

describe RailsAdmin::MainController do
  describe "if logged in as matt" do
    before do
      @identity = Identity.find_by_short_name("matt_zumwalt")
      if @identity.nil?
        @identity = FactoryGirl.create :identity
        @identity.short_name = "matt_zumwalt"
        @identity.save
      end
      log_in @identity.login_credential
    end
    it "should allow access" do
      visit "/admin"
      page.should have_content 'Site administration'
    end
  end
  describe "if not logged in as matt" do
    before do
      @identity = FactoryGirl.create :identity
      log_in @identity.login_credential
    end
    it "should NOT allow access" do
      visit "/admin"
      page.should_not have_content 'Site administration'
      page.should have_content 'Your Pools'
    end
  end

end
