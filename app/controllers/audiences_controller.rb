class AudiencesController < ApplicationController
  #load_resource :identity, :find_by => :short_name, :only=>[:index, :create]
  #load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity, :only=>[:index, :create]
  load_and_authorize_resource :audience_category, :only=>[:index, :create]
  load_and_authorize_resource :only=>[:show, :edit, :update]

  before_filter :move_json_filters_to_filters_attributes, only: [:create, :update]

  def index
    @audiences = @audience_category.audiences
    respond_to do |format|
      format.json { render :json=> @audiences.map {|audience| serialize_audience(audience) }}
    end
  end

  def show
    respond_to do |format|
      format.json { render :json=>serialize_audience(@audience) }
    end
  end

  def create
    @audience = @audience_category.audiences.build(audience_params)
    @audience.save
    respond_to do |format|
      format.json { render :json=>serialize_audience(@audience) }
    end
  end

  def update
    @audience.update_attributes(audience_params)
    respond_to do |format|
      format.json { render :json=>serialize_audience(@audience) }
    end
  end

  private

  def audience_params
    params.require(:audience).permit(:description, :name, {member_ids:[]}, filters_attributes: [:id, :_destroy, :field_name, :operator, {values:[]}, :association_code, :filter_type])
  end

  def move_json_filters_to_filters_attributes
    if params["filters"]
      to_move = params["filters"]
    elsif params["audience"]["filters"]
      to_move = params["audience"]["filters"]
    end
    if to_move && params["audience"]["filters_attributes"].nil?
      params["audience"]["filters_attributes"] = to_move
    end
  end

  def serialize_audience(audience)
    audience.as_json.merge({pool_name:params[:pool_id], identity_name:params[:identity_id]})
  end


end
