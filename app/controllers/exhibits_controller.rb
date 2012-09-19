class ExhibitsController < ApplicationController
  include Cocupu::Search

  load_and_authorize_resource 
  load_and_authorize_resource :pool, :only=>[:create, :update]

  def index
  end

  def edit
  end

  def show
    # Constrain results to this pool
    fq = "pool:#{@exhibit.pool_id}"
    ## TODO need a better way to get the query fields.  Not all these models are necessarily in this pool
    query_fields = Model.all.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
    (solr_response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'search', :fq=>fq, 'facet.field' => ['name_s', 'model_name']})
    
    @total = solr_response["numFound"]
    @results = Node.find_all_by_persistent_id(solr_response['docs'].map{|d| d['id']})
  end

  def new
  end

  def create
    @exhibit.pool = @pool
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/)
    @exhibit.save
    redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit)
  end

  def update
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/)
    @exhibit.save
    redirect_to identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit)
  end


end
