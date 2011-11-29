require 'spec_helper'

describe WelcomeController do
  it "should route" do
    {:get=>'/'}.should route_to(:controller=>'welcome', :action=>'index')
    root_path.should == '/'
  end
  it "should show the index" do
    get 'index'
    response.should be_success
  end


end
