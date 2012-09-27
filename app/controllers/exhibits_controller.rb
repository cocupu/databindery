class ExhibitsController < ApplicationController
  include Cocupu::Search

  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :through=>:pool, :except=>:create

  ExhibitsController.solr_search_params_logic += [:add_pool_to_fq]
  
  def index
  end

  def edit
    @fields = @pool.all_fields
  end

  def show
    # Constrain results to this pool
    query_fields = @exhibit.pool.models.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
    facets = @exhibit.facets.map{ |key| Node.solr_name(key, 'facet')}
    facets << 'model_name'
    (@response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'search', 'facet.field' => facets})
    
    @total = @response["numFound"]
    @results = Node.find(@response['docs'].map{|d| d['version']})
  end

  def new
    @fields = @pool.all_fields
  end

  def create
    authorize! :create, Exhibit
    @exhibit = Exhibit.new(params.require(:exhibit).permit(:title, :facets, :index_fields))
    @exhibit.pool = @pool
    @exhibit.save
    redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit)
  end

  def update
    @exhibit.update_attributes(params.require(:exhibit).permit(:title, :facets, :index_fields))
    redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit)
  end

  protected

  def add_pool_to_fq(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "pool:#{@exhibit.pool_id}"

  end


end
