class ExhibitsController < ApplicationController

  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :through=>:pool, :except=>:create

  
  def index
  end

  def edit
    @fields = @pool.all_fields
  end

  def new
    @fields = @pool.all_fields
  end

  def create
    authorize! :create, Exhibit
    @exhibit = Exhibit.new(params.require(:exhibit).permit(:title, :facets, :index_fields))
    @exhibit.pool = @pool
    @exhibit.save
    redirect_to identity_pool_search_path(@identity, @pool, perspective: @exhibit.id), :notice=>"Exhibit created"
  end

  def update
    @exhibit.update_attributes(params.require(:exhibit).permit(:title, :facets, :index_fields))
    redirect_to identity_pool_search_path(@identity, @pool, perspective: @exhibit.id), :notice=>"Exhibit updated"
  end


end
