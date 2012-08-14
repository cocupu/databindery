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
      redirect_to edit_model_path(@model), :notice=>"Entity has been created"
    else
      render action: :new
    end
  end

  def edit
    @models = Model.accessible_by(current_ability) # for the sidebar
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = ['Has Many', 'Has One', 'Ordered List', 'Unordered List']
    @field_types = ['Text Field', 'Text Area', 'Date']
  end
end
