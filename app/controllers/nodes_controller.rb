class NodesController < ApplicationController
  load_and_authorize_resource :except=>:index
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
          @nodes.to_json
          # @nodes.to_json(:only=>[:id, :persistent_id, :data], 
          #                :methods=>[:title],
          #                :include=>[:model => {:only=>[:fields, :label, :name]}]) 
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
    @node.pool = current_pool
    @node.save!
    redirect_to node_path(@node.id), :notice=>"#{model.name} created"
  end

  def update
    @node.attributes = params[:node]
    new_version = @node.update
    redirect_to node_path(new_version), :notice=>"#{@node.model.name} updated"
  end
end
  
