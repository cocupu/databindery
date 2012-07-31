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
      before { sign_in FactoryGirl.create :login }
      subject { get :index }
      it { should render_template("dashboard") }
      it "should assign models" do
        assigns[:models].should == @my_model
      end
    end
  end


end
