class SpawnJobsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :identity, :find_by => :short_name, :only=>[:index, :show, :edit]
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :except=>[:create, :new]
  load_resource :mapping_template
  load_resource :worksheet, :only=>[:create]


  # If you do not provide params[:worksheet_id] but instead provide params[:node_id]
  # A spreadsheet will be decomposed for you based on the given Node id.  Note: The node_id can be the 
  # persistent_id for that Node or the database key of a specific version of the Node.  
  def new
    authorize! :create, Node
    if params[:worksheet_id] 
      @worksheet = Worksheet.find(params[:worksheet_id])
    elsif params[:source_node_id]
      if params[:job_log_id]
        @job = DecomposeSpreadsheetJob.new(params[:source_node_id], JobLogItem.find(params[:job_log_id]))
      else
        # if params[:skip_decompose], no @job is created.
        unless params[:skip_decompose]
          @job = DecomposeSpreadsheetJob.new(params[:source_node_id], JobLogItem.new)
          @job.enqueue #start the logger
          # @job.perform
        end
      end
      @worksheet = Bindery::Spreadsheet.find_by_identifier(params[:source_node_id]).worksheets.first
    else 
      raise ArgumentError, "You must provide either worksheet_id or node_id parameter in order to create a new MappingTemplate."
    end
    @model = Model.find( @mapping_template.model_mappings.first[:model_id] ) unless @mapping_template.nil? || @mapping_template.model_mappings.empty?
  end

  def create
    authorize! :create, Node
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
   
    @worksheet.reify(@mapping_template, @pool)
    flash[:notice] = "Spawning #{@worksheet.rows.count} entities from #{@worksheet.spreadsheet.title}. Refresh this page to see them appear in your search results as they spawn."
    redirect_to identity_pool_search_path(identity.short_name, @pool)
  end

  def show
  end
end
