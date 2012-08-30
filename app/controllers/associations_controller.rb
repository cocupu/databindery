class AssociationsController < ApplicationController
  load_and_authorize_resource :model, :only=>:create
  load_and_authorize_resource :node, :only=>[:index, :create], :find_by => :persistent_id
  def create
    if @model
      params[:association][:label] = Model.find(params[:association][:references]).name.capitalize
      ## TODO association code should be unique
      params[:association][:code] = Model.field_name(params[:association][:name])
      @model.associations << params[:association]
      @model.save!
      respond_to do |format|
        format.html { redirect_to edit_model_path(@model) }
        format.json { head :no_content }
      end
    elsif @node
      association = @node.associations[params[:association][:code]] || []
      association << params[:association][:target_id]
      @node.associations[params[:association][:code]] = association
      @node.save

      render :text=>'ok'
    end
  end

  def index
    model = @node.model
    associations = {}
    model.associations.map{|a| a[:name]}.each do |assoc_name|
      associations[assoc_name] = []
      if @node.associations[assoc_name]
        @node.associations[assoc_name].each do |id|
          node = Node.find_by_persistent_id(id)
          associations[assoc_name] <<  node.association_display if node
        end
      end
    end
    associations['undefined'] = []
    if @node.associations['undefined']
      @node.associations['undefined'].each do |id| 
        node = Node.find_by_persistent_id(id)
        associations['undefined'] << node.association_display if node
      end
    end
    respond_to do |format|
      format.json do
        render json: associations.to_json()
      end
    end
  end
end
