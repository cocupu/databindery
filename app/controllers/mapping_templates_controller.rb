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
      if params[:node_id].include?("-")
        @source_node = Bindery::Spreadsheet.version_with_latest_file_binding(params[:node_id])
      else
        current_node = Bindery::Spreadsheet.find_by_identifier(params[:node_id])
        @source_node = current_node.version_with_current_file_binding
      end
      @worksheet = @source_node.worksheets.first
    else 
      raise ArgumentError, "You must provide either mapping_template[worksheet_id] or node_id parameter in order to create a new MappingTemplate."
    end
    mappings = []
    header_row = @worksheet.rows[0] #this is a bad assumption
    header_row.values.each_with_index { |value, n| mappings << {:source=> (n+65).chr, :label => value }}
    @mapping_template = MappingTemplate.new(:model_mappings=>[{:field_mappings=>mappings}])
    respond_to do |format|
      format.html { render action: 'new' }
      format.json { render json: @mapping_template }
    end
  end

  def create
    authorize! :create, MappingTemplate
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @mapping_template = MappingTemplate.new(owner: identity, pool: @pool)
    begin
      @mapping_template.attributes = mapping_template_params
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:alert] = e.record.errors.full_messages.join("\n")
      render :action=>'new'
      return
    end
    @mapping_template.save!

    respond_to do |format|
      format.html { redirect_to new_identity_pool_spawn_job_path(@identity, @pool, worksheet_id:params[:worksheet_id], mapping_template_id:@mapping_template.id, skip_decompose:true, classic:true)}
      format.json { render json: @mapping_template }
    end
  end

  def update
    begin
      @mapping_template.attributes = mapping_template_params
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:alert] = e.record.errors.full_messages.join("\n")
      render :action=>'new'
      return
    end
    @mapping_template.save!
    respond_to do |format|
      #format.html { redirect_to :action => :edit }
      format.json { render json: @mapping_template }
    end
  end

  def show
  end

  private

  def mapping_template_params
    params.require(:mapping_template).permit(:row_start,:pool_id).tap do |whitelisted|
      # if simplified json was submitted, rearrange it to work with @mapping_template.attributes=, which expects multiple model mappings
      if params[:mapping_template][:model_mappings_attributes].nil? && params[:mapping_template][:model_mappings]
        model_mapping = params[:mapping_template][:model_mappings][0]
        model_mapping[:field_mappings_attributes] = {}
        model_mapping[:field_mappings].each_with_index do |field_mapping, index|
          model_mapping[:field_mappings_attributes][index] = field_mapping
        end
        whitelisted[:model_mappings_attributes] = {"0"=>model_mapping}
      else
        #remove template fields
        params[:mapping_template][:model_mappings_attributes].each do |key, mma|
          mma['field_mappings_attributes'].delete('new_field_mappings')
        end
        # whitelist model_mappings_attributes
        if params[:mapping_template][:model_mappings_attributes]
          whitelisted[:model_mappings_attributes] = params[:mapping_template][:model_mappings_attributes]
        end
      end
    end
  end

end
