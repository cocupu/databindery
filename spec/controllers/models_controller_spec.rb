require 'spec_helper'

describe ModelsController do
  describe "index" do
    before do
      @model = Model.create!(:name=>'Car', :owner=> FactoryGirl.create(:identity), :fields=>{'doors'=>"Number of Doors", 'speed'=>'Top Speed'})
    end
    it "should show models" do
      get :index
      assigns[:models].should include @model
      response.should be_success
    end
  end

end
