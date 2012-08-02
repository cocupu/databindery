class ExhibitsController < ApplicationController
  include Blacklight::SolrHelper
  include ActiveSupport::Benchmarkable

  load_and_authorize_resource 

  def blacklight_config 
    @config ||= Cocupu::Config.new
  end

  def index
  end

  def edit
  end

  def show
    # Constrain results to this pool
    fq = "pool_s:#{@exhibit.pool_id}"
    ## TODO need a better way to get the query fields.  Not all these models are necessarily in this pool
    query_fields = Model.all.map {|model| model.fields.map{ |key, val| Node.solr_name(key) } }.flatten.uniq
    (solr_response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool_s"]).join(' '), :qt=>'search', :fq=>fq, 'facet.field' => ['name_s', 'model']})
    
    @total = solr_response["numFound"]
    @results = Node.find_all_by_persistent_id(solr_response['docs'].map{|d| d['id']})
  end

  def new
  end

  def create
    @exhibit.pool = current_pool
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/)
    @exhibit.save
    redirect_to @exhibit
  end

  def update
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/)
    @exhibit.save
    redirect_to @exhibit
  end

  private


  # a solr query method
  # given a user query, return a solr response containing both result docs and facets
  # Returns a two-element array (aka duple) with first the solr response object,
  # and second an array of SolrDocuments representing the response.docs
  def get_search_results(user_params = params || {}, extra_controller_params = {})

    facet_fields = {}
    solr_response = {}
    benchmark "get_search_results" do
      params = self.solr_search_params(user_params).merge(extra_controller_params)
      res = Cocupu.solr.get('select', :params=>params)
      logger.debug "Query to solr: #{params}"
      logger.debug "Solr resopnse :#{res}"
      solr_response = force_to_utf8(res['response'])
      facet_fields = res['facet_counts']['facet_fields']
    end
    [solr_response, facet_fields]
  end

  # Looks up a search field blacklight_config hash from search_field_list having
  # a certain supplied :key. 
  def search_field_def_for_key(key)
    blacklight_config.search_fields[key]
  end


end
