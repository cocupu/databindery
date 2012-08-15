class NodesController < ApplicationController
  load_and_authorize_resource :except=>:index

  def index
    if params[:model_id]
      @model = Model.find(params[:model_id])
      authorize! :read, @model
      @nodes = @model.nodes.accessible_by(current_ability)
    else
      @nodes = Node.accessible_by(current_ability)
    end
  end

  def new
    ## IF params[:binding] is passed, they are binding a file.
    ## ELSE IF params[:model_id] is passed, they are creating a new entity.
    @node.binding = params[:binding]
    @models = Model.accessible_by(current_ability)
  end

  def show
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
end
  
