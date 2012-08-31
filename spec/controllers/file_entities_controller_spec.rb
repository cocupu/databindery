require 'spec_helper'

describe FileEntitiesController do

  describe 'create' do
    before do
      @user = FactoryGirl.create :login_credential
      @pool = FactoryGirl.create :pool, :owner=>@user.identities.first
      sign_in @user
    end
    it "should create and return json" do
      post :create, :format=>:json, :binding=>'1231249', :pool_id=>@pool.id
      response.should be_successful
      json = JSON.parse(response.body)
      json.keys.should include('id')
    end
  end

end
