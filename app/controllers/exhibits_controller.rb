class ExhibitsController < ApplicationController

  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :through=>:pool, :except=>:create

  before_filter :cleanup_filter_params, only: [:create, :update]
  
  def index
    @exhibits = @pool.exhibits
  end

  def edit
    @fields = @pool.all_fields
  end

  def new
    @fields = @pool.all_fields
  end

  def create
    authorize! :create, Exhibit
    @exhibit = Exhibit.new(exhibit_params)
    @exhibit.pool = @pool
    @exhibit.save
    redirect_to identity_pool_search_path(@identity, @pool, perspective: @exhibit.id), :notice=>"Exhibit created"
  end

  def update
    @exhibit.update_attributes(exhibit_params)
    redirect_to edit_identity_pool_exhibit_path(@identity, @pool, @exhibit.id), :notice=>"Exhibit updated"
  end

  private

  def exhibit_params
    params.require(:exhibit).permit(:title, {facets:[]}, {index_fields: []}, filters_attributes: [:id, :_destroy, :field_name, :operator, {values:[]}, :association_code, :filter_type])
  end

  def cleanup_filter_params
    if params[:exhibit][:filters_attributes]
      params[:exhibit][:filters_attributes].delete_if {|fp| fp[:field_name] == "model"} unless params[:exhibit][:restrict_models] == "1"
      params[:exhibit][:filters_attributes].delete_if do |fp|
        fp[:field_name].nil? || fp[:field_name].empty? || fp[:values].nil? || fp[:values].empty? || fp[:values].first.empty? || fp[:operator].nil? || fp[:operator].empty?
      end
      params[:exhibit][:filters_attributes].each do |fp|
        fp[:values] = [fp[:values]] unless fp[:values].kind_of?(Array)
      end
    end
  end
end
