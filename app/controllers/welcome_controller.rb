class WelcomeController < ApplicationController
  layout 'full_width'
  def index
    if user_signed_in?
      @models = Model.accessible_by(current_ability)
      @exhibits = Exhibit.accessible_by(current_ability)
      render 'dashboard'
    else
      render 'index'
    end
  end
end
