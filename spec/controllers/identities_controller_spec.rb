require 'spec_helper'

describe IdentitiesController do

  describe "index" do
    before do
      @identity = FactoryGirl.create :identity
      sign_in @identity.login_credential
    end
    it "should give a json formatted list of identities available for the current user" do
      identity2 = FactoryGirl.create :identity, login_credential: @identity.login_credential
      get :index
      response.should be_success
      assigns[:identities].count.should == 2
      assigns[:identities].should include(@identity)
      assigns[:identities].should include(identity2)
      json = JSON.parse(response.body)
      identity_json = json.select {|i| i["id"] == @identity.id}.first
      identity_json.delete("created_at")
      identity_json.delete("updated_at")
      identity_json.should == {"id"=>@identity.id, "name"=>@identity.name, "short_name"=>@identity.short_name, "url"=>"/#{@identity.short_name}"}
    end
    it "should allow searching for identities belonging to current_user" do
      get :index, q:"current_user"
      assigns[:identities].should == @identity.login_credential.identities.all
    end
  end

end
