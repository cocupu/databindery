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
    @field = {name: '', type: '', uri: '', multivalue: false}
    @association= {name: '', type: '', references: ''}
    @association_types = Bindery::Association::TYPES
    @field_types = [['Text Field', 'TextField'], ['Text Area', 'TextArea'], ['Number', 'IntegerField'], ['Date', 'DateField']]
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
    json = {id: m.id, url: model_path(m), associations: m.associations, fields: m.fields, name: m.name, label_field_id: m.label_field_id.to_s, allow_file_bindings: m.allow_file_bindings }
    json.merge!(pool: m.pool.short_name, identity: m.pool.owner.short_name) if m.pool
    json
  end

  # Whitelisted attributes for create/update
  def model_params
    if params.has_key?(:model)
      model_params = params.require(:model)
    else
      model_params = params
    end
    rename_json_fields_to_fields_attributes(model_params)
    rename_json_associations_to_associations_attributes(model_params)
    convert_label_field_code_to_id(model_params)
    model_params.permit(:name, :label_field_id, :allow_file_bindings, fields_attributes: [:id, :_destroy, :name, :type, :code, :uri, :references, :multivalue], associations_attributes: [:id, :_destroy, :name, :type, :code, :uri, :references, :multivalue])
  end

  # If label_field_id is set to a field code instead of a field id, replaces it with the id
  def convert_label_field_code_to_id(model_params)
    if model_params[:label_field_id]
      unless Field.exists?(model_params[:label_field_id])
        existing_field_with_matching_code = @model.fields.select {|f| f.code == model_params[:label_field_id]}.first
        if existing_field_with_matching_code
          field_with_matching_code = existing_field_with_matching_code
        else
          params_for_new_field = model_params.fetch(:fields_attributes, []).select {|f| f[:code] == model_params[:label_field_id]}.first
          if params_for_new_field
            field_with_matching_code = Field.create(params_for_new_field)
            model_params[:fields_attributes].delete(params_for_new_field)
            model_params[:fields_attributes] << {id:field_with_matching_code.id}
          end
        end
        if field_with_matching_code
          field_with_matching_code.save unless field_with_matching_code.id
          model_params[:label_field_id] = field_with_matching_code.id
        end
      end
    end
  end

  # json objects list the filters as :filters, not :filters_attributes
  # this renames those submitted params so that they will be applied properly by update_attributes
  def rename_json_fields_to_fields_attributes(target_hash)
    # Grab the fields params out of the full submitted params hash
    if params["fields"]
      to_move = params["fields"]
    elsif params["model"]["fields"]
      to_move = params["model"]["fields"]
    end
    # Write the filters params into the target_hash as filters_attributes
    if to_move && target_hash["fields_attributes"].nil?
      target_hash["fields_attributes"] = to_move
    end
  end

  def rename_json_associations_to_associations_attributes(target_hash)
    # Grab the fields params out of the full submitted params hash
    if params["associations"]
      to_move = params["associations"]
    elsif params.has_key?(:model) && params["model"]["associations"]
      to_move = params["model"]["associations"]
    end
    # Write the filters params into the target_hash as filters_attributes
    if to_move && target_hash["associations_attributes"].nil?
      target_hash["associations_attributes"] = to_move
    end
  end
end
