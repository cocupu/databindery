class AudienceCategoriesController < ApplicationController
  load_resource :identity, :find_by => :short_name, :only=>[:index, :create]
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity, :only=>[:index, :create]
  load_and_authorize_resource :only=>[:show, :edit, :update]

  before_filter :move_json_audiences_to_audiences_attributes, only: [:create, :update]

  def index
    @audience_categories = @pool.audience_categories
    respond_to do |format|
      format.json { render :json=> @audience_categories.map{|category| serialize_category(category)}}
    end
  end

  def show
    respond_to do |format|
      format.json { render :json=>serialize_category(@audience_category) }
    end
  end

  def create
    @audience_category = @pool.audience_categories.build(audience_category_params)
    @audience_category.save
    respond_to do |format|
      format.json { render :json=>serialize_category(@audience_category) }
    end
  end

  def update
    @audience_category.update_attributes(audience_category_params)
    respond_to do |format|
      format.json { render :json=>serialize_category(@audience_category)  }
    end
  end

  private

  def audience_category_params
    params.require(:audience_category).permit(:description, :name, audiences_attributes:[:description, :name, :position, :id, :_destroy])
  end

  def move_json_audiences_to_audiences_attributes
    if params["audience_category"]["audiences"] && params["audience_category"]["audiences_attributes"].nil?
      params["audience_category"]["audiences_attributes"] = params["audience_category"]["audiences"]
    end
  end

  def serialize_category(category)
    context_info = {"pool_name"=>params[:pool_id], "identity_name"=>params[:identity_id]}
    h = category.as_json.merge(context_info)
    h["audiences"].each {|audience| audience.merge!(context_info)}
    h
  end


end
