class MappingTemplatesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :except=>[:create, :new]


  # If you do not provide params[:mapping_template][:worksheet_id] but instead provide params[:node_id]
  # A spreadsheet will be decomposed for you based on the given Node id.  Note: The node_id can be the 
  # persistent_id for that Node, or the database key of a specific version of the Node.  
  def new
    authorize! :create, MappingTemplate
    if params[:mapping_template] && params[:mapping_template][:worksheet_id]
      @worksheet = Worksheet.find(params[:mapping_template][:worksheet_id])
    elsif params[:node_id]
      unless params[:skip_decompose]
        @job = DecomposeSpreadsheetJob.new(params[:node_id], JobLogItem.new)
        @job.enqueue #start the logger
        @job.perform
      end
      @worksheet = Bindery::Spreadsheet.find_by_identifier(params[:node_id]).worksheets.first
    else 
      raise ArgumentError, "You must provide either mapping_template[worksheet_id] or node_id parameter in order to create a new MappingTemplate."
    end
    mappings = []
    header_row = @worksheet.rows[0] #this is a bad assumption
    header_row.values.each_with_index { |value, n| mappings << {:source=> (n+65).chr, :label => value }}
    @mapping_template = MappingTemplate.new(:model_mappings=>[{:field_mappings=>mappings}])
  end

  def create
    @worksheet = Worksheet.find(params[:worksheet_id])
    authorize! :create, MappingTemplate
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @mapping_template = MappingTemplate.new(owner: identity, pool: @pool)
    params[:mapping_template][:model_mappings_attributes].each do |key, mma|
      #remove template fields
      mma['field_mappings_attributes'].delete('new_field_mappings')
    end
    begin
      @mapping_template.attributes = params[:mapping_template]
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:alert] = e.record.errors.full_messages.join("\n")
      render :action=>'new'
      return
    end
    @mapping_template.save!
    @worksheet.reify(@mapping_template, @pool)
    flash[:notice] = "Spawning #{@worksheet.rows.count} entities from #{@worksheet.spreadsheet.title}."
    redirect_to identity_pool_mapping_template_path(identity.short_name, @pool, @mapping_template)
  end

  def show
  end
end
