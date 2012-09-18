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
        @identity = FactoryGirl.create :identity
        pool = FactoryGirl.create :pool, :owner=>@identity
        @exhibit = FactoryGirl.create(:exhibit, pool: pool)
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :index 
        response.should render_template("dashboard") 
        assigns[:exhibits].should == [@exhibit]
      end
    end
  end


end
