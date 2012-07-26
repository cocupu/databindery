class MappingTemplatesController < ApplicationController
  layout 'full_width'
  before_filter :authenticate_login_credential!


  def new
    @worksheet = Worksheet.find(params[:mapping_template][:worksheet_id])
    @mapping_template = MappingTemplate.new(:models=>[{:field_mappings=>{''=>''}}])
  end

  def create
    @worksheet = Worksheet.find(params[:worksheet_id])
    @mapping_template = MappingTemplate.new()
    params[:mapping_template][:models_attributes].delete("new_models")
    begin
      @mapping_template.attributes = params[:mapping_template]
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:error] = e.record.errors.full_messages
      render :action=>'new'
      return
    end
    @mapping_template.save!
    @worksheet.reify(@mapping_template, current_pool)
    redirect_to @mapping_template
  end

  def show
    @mapping_template = MappingTemplate.find(params[:id])
  end
end
