class FieldsController < ApplicationController
  load_and_authorize_resource :model
  def create
    render :text=>"OK"
  end
end
