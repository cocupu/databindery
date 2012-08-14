require 'spec_helper'

describe AssociationsController do
  before do
    @user = FactoryGirl.create :login
    @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
    @associated_model = FactoryGirl.create(:model, owner: @user.identities.first)
    @not_my_model = FactoryGirl.create(:model)
  end
  describe "create" do
    describe "when not logged on" do
      it "should redirect to root" do
        post :create, :model_id=>@my_model.id 
        response.should redirect_to root_path
      end
    end

    describe "when logged on" do
      before do
        sign_in @user
      end
      it "should redirect on a model that's not mine " do
        post :create, :model_id=>@not_my_model.id 
        response.should redirect_to root_path
      end
      it "should be successful" do
        post :create, :model_id=>@my_model.id, :association=>{type: 'Has One', name: 'talks', references: @associated_model.id}
        @my_model.reload.associations.should == 
           [{"type" => 'Has One', "name"=>"talks", "references" => @associated_model.id.to_s}]
        response.should redirect_to edit_model_path(@my_model)
      end
    end
  end

end
