class SpawnJobsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :identity, :find_by => :short_name, :only=>[:index, :show, :edit]
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :except=>[:create, :new]
  load_resource :mapping_template
  before_filter :load_source_node, only: [:new, :create]

  # If you do not provide params[:worksheet_id] but instead provide params[:node_id]
  # A spreadsheet will be decomposed for you based on the given Node id.  Note: The node_id can be the 
  # persistent_id for that Node or the database key of a specific version of the Node.  
  def new
    authorize! :create, Node
    if params[:worksheet_id] 
      @worksheet = Worksheet.find(params[:worksheet_id])
    elsif @source_node
      @worksheet = @source_node.worksheets.first
      if params[:job_log_id]
        @job = DecomposeSpreadsheetJob.new(params[:source_node_id], JobLogItem.find(params[:job_log_id]))
      else
        # If there is already a decomposed worksheet, no @job is queued.
        # You can force decomposition with params[:force_decompose] == "true"
        if @worksheet.nil? || params[:force_decompose]
          @job = DecomposeSpreadsheetJob.new(params[:source_node_id], JobLogItem.new)
          @job.enqueue #start the logger
          # @job.perform
        else
          # Create a stub successful job for rendering in the view
          @job = DecomposeSpreadsheetJob.new(params[:source_node_id], JobLogItem.new)
          @job.success
        end
      end
    else 
      raise ArgumentError, "You must provide either worksheet_id or node_id parameter in order to create a new MappingTemplate."
    end
    @model = Model.find( @mapping_template.model_mappings.first[:model_id] ) unless @mapping_template.nil? || @mapping_template.model_mappings.empty?
    if params[:classic]
      render file: "spawn_jobs/new-static"
    end
  end

  def create
    authorize! :create, Node
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @spawn_job = SpawnJob.new(pool:@pool, node:@source_node, mapping_template:@mapping_template)
    @spawn_job.reify_rows
    @spawn_job.save!
    flash[:notice] = "Spawning #{@source_node.parsed_sheet.last_row} entities from #{@source_node.title}. Refresh this page to see them appear in your search results as they spawn."
    redirect_to identity_pool_search_path(identity.short_name, @pool)
  end

  def show
  end

  private
  def load_source_node
    if params[:source_node_id]
      if params[:source_node_id].kind_of?(Fixnum) || !params[:source_node_id].include?("-")
        current_node = Bindery::Spreadsheet.find_by_identifier(params[:source_node_id])
        @source_node = current_node.version_with_current_file_binding
      else
        @source_node = Bindery::Spreadsheet.version_with_latest_file_binding(params[:source_node_id])
      end
    end
  end
end
