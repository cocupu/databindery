class NodesController < ApplicationController
  include Blacklight::Controller
  include Blacklight::SolrHelper
  load_and_authorize_resource :except=>[:index, :search, :update, :create, :find_or_create], :find_by => :persistent_id
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_resource :model, through: :node, singleton: true, only: [:show]

  def index
    if params[:model_id]
      @model = Model.find(params[:model_id])
      authorize! :read, @model
      @nodes = @model.nodes.where("nodes.pool_id = ?", @pool)
    else
      @nodes = @pool.nodes
    end
    respond_to do |format|
      format.html do
        @models = @pool.models
      end
      format.json do
        render json: 
          @nodes.to_json(:only=>[:id, :persistent_id, :data, :associations, :model_id])
      end
    end
  end

  def search
    if params[:model_id]
      @model = Model.find(params[:model_id])
      authorize! :read, @model
    end

    # Constrain results to this pool
    fq = "pool:#{@pool.id}"
    fq += " AND model:#{@model.id}" if @model
    fq += " AND format:Node"

    ## TODO do we need to add query_fields for File entities?
    query_fields = @pool.models.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
    (solr_response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'search', :fq=>fq, :rows=>1000, 'facet.field' => ['name_si', 'model']})
    
    # puts "# of solr_docs: #{solr_response.docs.length}"
    # puts "solr_response: #{solr_response.docs}"
    @results = solr_response.docs.map{|d| Node.find_by_persistent_id(d['id'])}
    

    respond_to do |format|
      format.json do
        render json: @results
      end
    end
  end

  def new
    @models = @pool.models
    ## IF params[:binding] is passed, they are binding a file.
    ## ELSE IF params[:model_id] is passed, they are creating a new entity.
    if params[:binding] 
      @node.binding = params[:binding]
      render :new_binding
      return
    end
    @node.model = Model.find(params[:model_id])
    authorize! :read, @node.model
  end

  def show
    respond_to do |format|
      format.mp3 do
        if @node.model == Model.file_entity
          send_data @node.content, :type=>@node.mime_type, :disposition => 'inline'
        else
          render :file => "public/404", :status => :not_found, :layout=>nil
        end
      end
      format.ogg do
        if @node.model == Model.file_entity
          require 'open3'
          ## by default rails sets the encoding to UTF_8, this causes a UndefinedConversionError
          ## when dealing with binary data.
          Encoding.default_internal = nil
          ## run mpg321 reading from stdin, in quiet mode, encoding to wav
          ## take that stream and encode it with oggenc in quiet mode 
          ## read the output (stdout) and stream it to the web client
          stdin, stdout, wait_thr = Open3.popen2('mpg321 - -q -w -|oggenc - -Q')
          stdin.write @node.content
          stdin.close
          send_data stdout.read, :type=>'ogg', :disposition => 'inline'
          stdout.close
          Encoding.default_internal = Encoding::UTF_8 #Restore default expected by rails
        else
          render :file => "public/404", :status => :not_found, :layout=>nil
        end
      end
      format.json { render json: serialize_node(@node) }
      format.html 
    end
  end
  
  def create
    authorize! :create, Node
    @node = Node.new(node_params)
    @node.modified_by = @identity
    begin
      model = @pool.models.find(params[:node][:model_id])
    rescue ActiveRecord::RecordNotFound 
      #User didn't have access to the model they were trying to set.
      redirect_to new_identity_pool_node_path(@identity, @pool, :binding=>@node.binding)
      return
    end
    @node.model = model
    @node.pool = @pool
    @node.save!
    respond_to do |format|
      format.html { redirect_to identity_pool_search_path(@identity, @pool), :notice=>"#{model.name} created" }
      format.json { render :json=>serialize_node(@node)}
    end
  end
  
  # Uses advanced search request handler to find Nodes matching the request.
  # Currently only searches against attribute values.  Does not search against associations (though associations in the create request will be applied to the Node if created.)
  def find_or_create
    authorize! :create, Node
    init_node_from_params
    
    # Find...
    # Constrain results to this pool
    fq = "pool:#{@pool.id}"
    fq += " AND model:#{@model.id}" if @model
    fq += " AND format:Node"
    
    query_parts = []
    @node.solr_attributes.each_pair do |key, value|
      query_parts << "#{key}:\"#{value}\""
    end
    query = query_parts.join(" && ")
    # puts query

    ## TODO do we need to add query_fields for File entities?
    query_fields = @pool.models.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
    (solr_response, @facet_fields) = get_search_results( {:q=>query}, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'advanced', :fq=>fq, :rows=>10, 'facet.field' => ['name_si', 'model']})
    
    #puts "solr_response: #{solr_response.docs}"
    
    # If any docs were found, load the first result as a node and return that.  
    # Otherwise, create a new one based on the params provided.
    first_result = solr_response.docs.first
    if first_result.nil?
      @node.save
      flash[:notice] = "Created a new #{@node.model.name} based on your request."
    else
      @node =  Node.find_by_persistent_id(first_result['id'])
      flash[:notice] = "Found a #{@node.model.name} matching your query."
    end
    
    respond_to do |format|
      format.html { render file: "nodes/show"}
      format.json { render :json=>serialize_node(@node)}
    end
  end

  def update
    @node = Node.find_by_persistent_id(params[:id])
    authorize! :update, @node
    @node.attributes = node_params
    @node.modified_by = @identity
    new_version = @node.update
    respond_to do |format|
      format.html { redirect_to identity_pool_solr_document_path(@identity, @pool, new_version), :notice=>"#{@node.model.name} updated" }
      format.json { head :no_content }
    end
  end
  
  def destroy
    node_name = @node.title
    @pool = @node.pool
    @node.destroy
    flash[:notice] = "Deleted \"#{node_name}\"."
    redirect_to identity_pool_search_path(identity_id: current_identity, pool_id: @pool)
  end

  def attach_file
    @node = Node.find_by_persistent_id(params[:node_id])
    authorize! :attach_file, @node
    if @pool.default_file_store.nil?
      respond_to do |format|
        error = "You must set up a file store before attaching a file"
        format.html { redirect_to identity_pool_node_path(@identity, @pool, @node), :alert=>error   }
        format.json { render :json=>{:status=>:error, :errors=>[error]}, :status=>:unprocessable_entity}
      end
      return
    end


    new_version = @node.attach_file(params[:file_name], params[:file])
    respond_to do |format|
      format.html { redirect_to identity_pool_node_path(@identity, @pool, new_version), :notice=>"Attached file" }
      format.json { head :no_content }
    end

  end

  private

  # Whitelisted attributes for create/update
  def node_params
    if params.has_key?(:node)
      node_params = params.require(:node)
    else
      node_params = params
    end
    node_params.permit(:binding).tap do |whitelisted|
      if node_params[:data]
        whitelisted[:data] = node_params[:data]
      end
      if node_params[:associations]
        whitelisted[:associations] = node_params[:associations]
      end
    end
  end

  def serialize_node(n)
    hash = n.as_json.merge({url: identity_pool_node_path(n.pool.owner, n.pool, n), pool: n.pool.short_name, identity: n.pool.owner.short_name, binding: n.binding, model_id: n.model_id })
    ["id", "parent_id", "pool_id", "identity_id", "created_at", "updated_at"].each {|key| hash.delete(key)}
    return hash
  end

  def blacklight_solr
    @solr ||=  RSolr.connect(blacklight_solr_config)
  end

  def blacklight_solr_config
    Blacklight.solr_config
  end
  
  def init_node_from_params
    begin
      model = @pool.models.find(params[:node][:model_id])
    rescue ActiveRecord::RecordNotFound 
      #User didn't have access to the model they were trying to set.
      redirect_to new_identity_pool_node_path(@identity, @pool, :binding=>@node.binding)
      return
    end
    @node = Node.new(node_params)
    @node.model = model
    @node.pool = @pool
  end

end
  
