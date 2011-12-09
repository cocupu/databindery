class MappingTemplatesController < ApplicationController

  def new
    @worksheet = Worksheet.find(params[:mapping_template][:worksheet_id])
    @mapping_template = MappingTemplate.new(:models=>[TemplateModelMapping.new(:field_mappings=>[FieldMapping.new])])
  end

  def create
    @worksheet = Worksheet.find(params[:worksheet_id])
    @mapping_template = MappingTemplate.new()
    params[:mapping_template][:models_attributes].delete("new_models")
    @mapping_template.attributes = params[:mapping_template]
    if @mapping_template.save  
      ## TODO validate that we don't alread have models with these names
      create_models(@mapping_template.models)
      @worksheet.reify(@mapping_template)
      redirect_to :action=>'show', :id=>@mapping_template.id
    else
      flash[:error] = @mapping_template.models.collect {|m| m.errors.full_messages}.flatten 
      render :action=>'new'
    end
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
