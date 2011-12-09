require 'spec_helper'

describe ExhibitsController do
  it "should route" do
    exhibits_path.should == '/exhibits'
  end

  describe "index" do
    it "should be success" do
      get :index
      response.should be_successful
    end
  end

  describe "search" do
    it "should be success" do
      get :index, :q=>'Aluminum'
      assigns[:total].should == 1
      assigns[:results].should_not be_nil
      response.should be_successful
    end
  end


end
