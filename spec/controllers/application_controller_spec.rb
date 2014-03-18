require 'spec_helper'

describe ApplicationController do
  class ApplicationControllerSubclass < ApplicationController
  end

  controller(ApplicationControllerSubclass) do
    def index
      render :nothing => true
    end
  end
  
  it "should return CSRF/XSRF header" do
    get :index
    response.cookies["XSRF-TOKEN"].should == controller.send(:form_authenticity_token)
  end
  
end