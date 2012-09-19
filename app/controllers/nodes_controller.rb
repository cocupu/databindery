class NodesController < ApplicationController
  include Cocupu::Search
  load_and_authorize_resource :except=>[:index, :search], :find_by => :persistent_id
  load_and_authorize_resource :pool, :only=>[:create, :search], :find_by => :short_name, :through=>:identity
  layout 'full_width'

  def index
    if params[:model_id]
      @model = Model.find(params[:model_id])
      authorize! :read, @model
      @nodes = @model.nodes.accessible_by(current_ability)
    else
      @nodes = Node.accessible_by(current_ability)
    end
    respond_to do |format|
      format.html do
        @models = Model.accessible_by(current_ability) # for the sidebar
      end
      format.json do
        render json: 
          @nodes.to_json(:only=>[:id, :persistent_id, :data, :associations, :model_id])
          # @nodes.to_json(:only=>[:id, :persistent_id, :data], 
          #                :methods=>[:title],
          #                :include=>[:model => {:only=>[:fields, :label, :name]}]) 
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

    ## TODO need a better way to get the query fields.  Not all these models are necessarily in this pool
    query_fields = Model.accessible_by(current_ability).map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
    (solr_response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'search', :fq=>fq, 'facet.field' => ['name_s', 'model']})
    
    @results = solr_response['docs'].map{|d| Node.find_by_persistent_id(d['id'])}
    

    respond_to do |format|
      format.json do
        render json: @results
      end
    end
  end

  def new
    @models = Model.accessible_by(current_ability)
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
      format.html do
        @models = Model.accessible_by(current_ability) # for the sidebar
      end
      format.json { render json: @node }
    end
  end
  
  def create
    @node.binding = params[:node][:binding]
    begin
      model = Model.accessible_by(current_ability).find(params[:node][:model_id])
    rescue ActiveRecord::RecordNotFound 
      #User didn't have access to the model they were trying to set.
      redirect_to new_node_path(:binding=>@node.binding)
      return
    end
    @node.model = model
    @node.pool = @pool
    @node.save!
    redirect_to node_path(@node), :notice=>"#{model.name} created"
  end

  def update
    @node.attributes = params[:node]
    new_version = @node.update
    respond_to do |format|
      format.html { redirect_to node_path(new_version), :notice=>"#{@node.model.name} updated" }
      format.json { head :no_content }
    end
  end

end
  
