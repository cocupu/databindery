class MappingTemplatesController < ApplicationController
  def new
    @spreadsheet = Cocupu::Spreadsheet.find(params[:spreadsheet_id])
    @mapping_template = MappingTemplate.new(:spreadsheet=>@spreadsheet, :models=>[TemplateModelMapping.new(:field_mappings=>[FieldMapping.new])])
  end
  def create
    @spreadsheet = Cocupu::Spreadsheet.find(params[:spreadsheet_id])
    @mapping_template = MappingTemplate.new()
    @mapping_template.attributes = params[:mapping_template]
    @mapping_template.save!  
    ## TODO validate that we don't alread have models with these names
    create_models(@mapping_template.models)
    @spreadsheet.reify(@mapping_template)
    redirect_to :action=>'show', :id=>@mapping_template.id
  end

  def show
    @mapping_template = MappingTemplate.find(params[:id])
  end

  protected


  def create_models(models_template)
    models_template.each {|model_template| create_model(model_template) }
  end

  def create_model(model_template)
    m_fields = model_template.field_mappings.map{|elem| Field.new(:label=>elem.label)}
    Model.create!(:name=>model_template.name, :m_fields=>m_fields)
  end
end
