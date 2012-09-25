class ModelsController < ApplicationController

  load_and_authorize_resource :pool, :only=>:create
  load_and_authorize_resource :except=>[:create, :update]

  layout 'full_width'

  def index

  end 

  def show
    respond_to do |format|
      format.json { render :json=>@model }
    end
  end

  def new
  end

  def create
    authorize! :create, Model
    @model = Model.new(params.require(:model).permit(:name, :label))
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @model.owner = identity
    @model.pool = @pool 
    if @model.save
      respond_to do |format|
        format.json { render :json=>@model}
        format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been created" }
      end
    else
      render action: :new
    end
  end

  def edit
    @models = Model.accessible_by(current_ability) # for the sidebar
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = Model::Association::TYPES
    @field_types = [['Text Field', 'text'], ['Text Area', 'textarea'], ['Date', 'date']]
  end

  def update
    @model = Model.find(params[:id])
    authorize! :update, @model
    @model.update_attributes(params.require(:model).permit(:name, :label)) 
    respond_to do |format|
      format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been updated" }
      format.json { head :no_content }
    end
  end
end
