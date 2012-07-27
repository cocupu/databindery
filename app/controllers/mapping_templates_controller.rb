class MappingTemplatesController < ApplicationController
  layout 'full_width'
  before_filter :authenticate_user!


  def new
    raise ArgumentError unless params[:mapping_template] && params[:mapping_template][:worksheet_id]
    @worksheet = Worksheet.find(params[:mapping_template][:worksheet_id])
    mappings = {}
    header_row = @worksheet.rows[0] #this is a bad assumption
    header_row.values.each_with_index { |value, n| mappings[(n+65).chr] = value }
    @mapping_template = MappingTemplate.new(:models=>{''=>{:field_mappings=>mappings}})
  end

  def create
    @worksheet = Worksheet.find(params[:worksheet_id])
    @mapping_template = MappingTemplate.new()
    params[:mapping_template][:models_attributes].delete("new_models")
    begin
      @mapping_template.attributes = params[:mapping_template]
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:alert] = e.record.errors.full_messages.join("\n")
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
