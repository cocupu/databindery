class AssociationsController < ApplicationController
  load_and_authorize_resource :model, :only=>:create
  load_and_authorize_resource :node, :only=>:index
  def create
    #TODO ensure that no-one creates an association on model called 'undefined'
    @model.associations << params[:association]
    @model.save!
    redirect_to edit_model_path(@model)
  end

  def index
    model = @node.model
    associations = {}
    model.associations.map{|a| a[:name]}.each do |assoc_name|
      associations[assoc_name] = []
      @node.associations[assoc_name].each do |id|
        associations[assoc_name] <<  Node.find(id).association_display
      end
      associations['undefined'] = []
      if (@node.associations['undefined']) 
        @node.associations['undefined'].each do |id| 
          associations['undefined'] << Node.find(id).association_display
        end
      end
    end
    respond_to do |format|
      format.json do
        render json: associations.to_json()
      end
    end
  end
end
