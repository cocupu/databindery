class AssociationsController < ApplicationController
  load_and_authorize_resource :model, :only=>:create
  load_and_authorize_resource :node, :only=>[:index, :create], :find_by => :persistent_id
  def create
    if @model
      @model.add_association(params[:association])
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
    respond_to do |format|
      format.json do
        render json: @node.associations_for_json.to_json()
      end
    end
  end
end
