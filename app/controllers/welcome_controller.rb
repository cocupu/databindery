class WelcomeController < ApplicationController
  layout 'margins'

  def index
    if user_signed_in?
      @pools = Pool.for_identity(current_identity)
      render 'dashboard'
    else
      render 'index'
    end
  end
end
