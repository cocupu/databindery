class ModelsController < ApplicationController

  load_and_authorize_resource

  layout 'full_width'

  def index

  end 

  def new
  end

  def create
    @model.owner = current_identity
    if @model.save
      redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been created"
    else
      render action: :new
    end
  end

  def edit
    @models = Model.accessible_by(current_ability) # for the sidebar
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = Model::Association::TYPES
    @field_types = [['Text Field', 'text'], ['Text Area', 'textarea'], ['Date', 'date']]
  end

  def update
    @model.update_attributes(params[:model]) 
    respond_to do |format|
      format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been updated" }
      format.json { head :no_content }
    end
  end
end
