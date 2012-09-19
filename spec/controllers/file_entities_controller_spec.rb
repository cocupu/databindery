require 'spec_helper'

describe FileEntitiesController do

  describe 'create' do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
      sign_in @identity.login_credential
    end
    it "should create and return json" do
      post :create, :format=>:json, :binding=>'1231249', :pool_id=>@pool.id, :identity_id=>@identity.short_name
      response.should be_successful
      json = JSON.parse(response.body)
      json.keys.should include('id')
    end
  end

end
