class AssociationsController < ApplicationController
  load_and_authorize_resource :model, :only=>:create
  load_and_authorize_resource :node, :only=>[:index, :create], :find_by => :persistent_id

  def create
    if @model
      @model.associations.create(association_params)
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
        if params[:filter] == "incoming"
          render json: {incoming: @node.incoming }
        else
          render json: @node.associations_for_json.to_json()
        end
      end
    end
  end

  def association_params
    if params.has_key?(:association)
      association_params = params.require(:association)
    else
      association_params = params
    end
    association_params.permit(:id, :_destroy, :name, :type, :code, :uri, :references, :multivalue)
  end
end
