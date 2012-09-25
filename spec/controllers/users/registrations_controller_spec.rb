require 'spec_helper'

describe Users::RegistrationsController do

  it "should allow identity short name" do
    controller.params = {user: { bad: 'evil', email: 'email', password: 'foo', identities_attributes: {"0"=>{"short_name"=>"Joe_Blow"}} }} 
    controller.resource_params.should == {"email"=>"email", "password"=>"foo", "identities_attributes"=>{"0"=>{"short_name"=>"Joe_Blow"}}}
  end

end
