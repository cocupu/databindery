class FieldsController < ApplicationController
  load_and_authorize_resource :model
  def create
    field_code = Model.field_name(params[:field][:name])
    @model.fields << params[:field].merge(code: field_code)
    @model.save!
    redirect_to edit_model_path(@model)
  end
end
