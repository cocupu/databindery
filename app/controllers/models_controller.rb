class ModelsController < ApplicationController

  load_and_authorize_resource

  layout 'full_width'

  def index

  end 

  def edit
    @models = Model.accessible_by(current_ability)
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = ['Has Many', 'Has One', 'Ordered List', 'Unordered List']
    @field_types = ['Text Field', 'Text Area', 'Date']
  end
end
