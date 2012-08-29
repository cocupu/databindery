class FieldsController < ApplicationController
  load_and_authorize_resource :model
  def create
    field_code = Model.field_name(params[:field][:name])
    @model.fields << params[:field].merge(code: field_code)
    @model.save!
    respond_to do |format|
      format.html { redirect_to edit_model_path(@model) }
      format.json { head :no_content }
    end
  end
end
