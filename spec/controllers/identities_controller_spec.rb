require 'spec_helper'

describe IdentitiesController do

  describe "index" do
    before do
      @identity = FactoryGirl.create :identity
      sign_in @identity.login_credential
    end
    it "should give a json formatted list of identites available for the current user" do
      get :index
      response.should be_success
      json = JSON.parse(response.body)
      json.should == [{'short_name' => @identity.short_name, 'url'=>"/#{@identity.short_name}"} ]
      
    end
  end

end
