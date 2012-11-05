require 'spec_helper'

describe Api::V1::TokensController do

  before do
    @identity = FactoryGirl.create :identity
  end

  it "should return an error" do
    post :create, :format=>:json
    response.code.should == '400'
    JSON.parse(response.body)['message'].should == 'The request must contain the user email and password.'
  end
  it "should return a token" do
    LoginCredential.any_instance.stub(:authentication_token=>'9t1pLZEAKQ819ZpBQ3uK')
    post :create, :email=>@identity.login_credential.email, :password=>@identity.login_credential.password, :format=>:json
    response.should be_successful
    JSON.parse(response.body)['token'].should == '9t1pLZEAKQ819ZpBQ3uK'
  end

end
