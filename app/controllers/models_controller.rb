class ModelsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' && c.request.params.include?(:auth_token) }

  load_and_authorize_resource :pool, :only=>[:create, :index], :find_by => :short_name
  load_and_authorize_resource :only=>[:show, :new, :edit]
  load_and_authorize_resource :through=>:pool, :only=>[:index]

  def index
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
    @model = Model.new(params.require(:model).permit(:name, :label, :associations, :fields))
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
    @models = Model.accessible_by(current_ability) # for the sidebar
    @field = {name: '', type: '', uri: '', multivalued: false}
    @association= {name: '', type: '', references: ''}
    @association_types = Model::Association::TYPES
    @field_types = [['Text Field', 'text'], ['Text Area', 'textarea'], ['Date', 'date']]
  end

  def update
    @model = Model.find(params[:id])
    authorize! :update, @model
    respond_to do |format|
      if @model.update_attributes(params.require(:model).permit(:name, :label, :associations, :fields)) 
          format.html { redirect_to edit_model_path(@model), :notice=>"#{@model.name} has been updated" }
          format.json { head :no_content }
      else
          format.html { render :action=>'edit' }
          format.json { render :json=>{:status=>:error, :errors=>@model.errors.full_messages}, :status=>:unprocessable_entity}
      end
    end
  end

  private

  def serialize_model(m)
    {id: m.id, url: model_path(m), pool: m.pool.short_name, identity: m.pool.owner.short_name, associations: m.associations, fields: m.fields, name: m.name, label: m.label }
  end
end
