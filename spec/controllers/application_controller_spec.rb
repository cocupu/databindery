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
    controller.allow_forgery_protection = true
    get :index
    expect(response.cookies["XSRF-TOKEN"]).to eq controller.send(:form_authenticity_token)
  end
  
end