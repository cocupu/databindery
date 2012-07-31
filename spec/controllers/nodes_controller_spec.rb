require 'spec_helper'

describe NodesController do
  before do
    @user = FactoryGirl.create :login
    @model = FactoryGirl.create :model
    sign_in @user
  end
  it "should load the model and its nodes" do
pending
    get :index, :model_id => @model.id
    response.should be_success
    assigns[:model].should be_kind_of Model
    assigns[:nodes].should be_kind_of Array
  end

end
