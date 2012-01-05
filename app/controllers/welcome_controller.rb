class WelcomeController < ApplicationController
  layout 'full_width'
  def index
    if login_credential_signed_in?
      render 'dashboard'
    else
      render 'index'
    end
  end
end
