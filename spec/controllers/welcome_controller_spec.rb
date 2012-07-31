require 'spec_helper'

describe WelcomeController do
  it "should route" do
    {:get=>'/'}.should route_to(:controller=>'welcome', :action=>'index')
    root_path.should == '/'
  end

  describe "GET #index" do
    describe "when not logged on" do
      subject { get :index }
      it { should render_template("index") }

    end
    describe "when logged on" do
      before do
        @user = FactoryGirl.create :login
        @my_model = FactoryGirl.create(:model, owner: @user.identities.first)
        @not_my_model = FactoryGirl.create(:model)
        sign_in @user
      end
      it "should be successful" do
        get :index 
        response.should render_template("dashboard") 
        assigns[:models].should == [@my_model]
      end
    end
  end


end
