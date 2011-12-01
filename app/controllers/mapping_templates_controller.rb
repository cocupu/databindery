class MappingTemplatesController < ApplicationController
  def create
    @mapping_template = MappingTemplate.new()
    @mapping_template.attributes = params[:mapping_template]
    @mapping_template.save!  
    render :text=>@mapping_template.inspect
  # TODO create the models
  # and run the SpreadsheetLineReifyJob (perhaps inside a ConcurrentJob)
  end
end
