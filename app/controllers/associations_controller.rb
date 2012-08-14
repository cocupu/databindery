class AssociationsController < ApplicationController
  load_and_authorize_resource :model
  def create
    @model.associations << params[:association]
    @model.save!
    redirect_to edit_model_path(@model)
  end
end
