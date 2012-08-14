class NodesController < ApplicationController
  load_and_authorize_resource :model, :only=>:index
  load_and_authorize_resource :through => :model, :only=>:index
  load_and_authorize_resource :except=>:index

  def index
  end

  def new
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
  
