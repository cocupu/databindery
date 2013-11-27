class ModelsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' && c.request.params.include?(:auth_token) }

  load_and_authorize_resource :pool, :only=>[:create, :index], :find_by => :short_name
  load_and_authorize_resource :only=>[:show, :new, :edit, :destroy]

  def index
    #@models = Model.for_identity_and_pool(current_identity, @pool)
    if can?(:edit, @pool)
      @models = @pool.models + Model.where(pool_id: nil)
    end
    respond_to do |format|
      format.html {}
      format.json do
        render :json=>@models.map { |m| serialize_model(m) }
      end
    end
  end 

  def show
    respond_to do |format|
      format.json { render :json=>serialize_model(@model)}
    end
  end

  def new
  end

  def create
    authorize! :create, Model
    @model = Model.new(model_params)
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @model.owner = identity
    @model.pool = @pool 
    if @model.save
      respond_to do |format|
        format.json { render :json=>serialize_model(@model)}
        format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been created" }
      end
    else
      render action: :new
    end
  end

  def edit
    @models = Model.for_identity(current_identity) # for the sidebar
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = Model::Association::TYPES
    @field_types = [['Text Field', 'text'], ['Text Area', 'textarea'], ['Date', 'date']]
  end

  def update
    @model = Model.find(params[:id])
    authorize! :update, @model
    respond_to do |format|
      if @model.update_attributes(model_params)
          format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been updated" }
          format.json { render :json=>serialize_model(@model) }
      else
          format.html { render :action=>'edit' }
          format.json { render :json=>{:status=>:error, :errors=>@model.errors.full_messages}, :status=>:unprocessable_entity}
      end
    end
  end
  
  def destroy
    @model = Model.find(params[:id])
    @pool = @model.pool
    model_name = @model.name
    @model.destroy
    flash[:notice] = "Deleted \"#{model_name}\" model."
    redirect_to identity_pool_models_path(identity_id: current_identity, pool_id: @pool)
  end

  private

  def serialize_model(m)
    json = {id: m.id, url: model_path(m), associations: m.associations, fields: m.fields, name: m.name, label: m.label, allow_file_bindings: m.allow_file_bindings }
    json.merge!(pool: m.pool.short_name, identity: m.pool.owner.short_name) if m.pool
    json
  end

  # Whitelisted attributes for create/update
  def model_params
    params.require(:model).permit(:name, :label, :allow_file_bindings).tap do |whitelisted|
      if params[:model][:fields]
        whitelisted[:fields] = params[:model][:fields]
      end
      if params[:model][:associations]
        whitelisted[:associations] = params[:model][:associations]
      end
    end
  end
end
