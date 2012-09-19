class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      @models = Model.accessible_by(current_ability)
      @pools = current_identity.pools
      @exhibits = Exhibit.accessible_by(current_ability)
      render 'dashboard'
    else
      render 'index'
    end
  end
end
