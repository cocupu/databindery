require 'spec_helper'

describe Devise::SessionsController do

  it "supports json lookup of currentUser" do
      post :create, :format=>:json

  end
end
