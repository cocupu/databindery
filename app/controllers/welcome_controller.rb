class WelcomeController < ApplicationController
  layout 'full_width'
  def index
    if user_signed_in?
      @models = current_identity.models
      render 'dashboard'
    else
      render 'index'
    end
  end
end
