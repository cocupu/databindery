class ExhibitsController < ApplicationController
  include Blacklight::SolrHelper
  include ActiveSupport::Benchmarkable

  def blacklight_config 
    @config ||= Cocupu::Config.new
  end

  def index
    @exhibits = Exhibit.list
  end
  def edit
    @exhibit = Exhibit.find(params[:id])
  end

  def show
    @exhibit = Exhibit.find(params[:id])
    ## TODO constrain fields just to models in this pool/exhibit
    query_fields = Field.list.map {|f| f.solr_name }.uniq
    (solr_response, @facet_fields) = get_search_results( params, {:qf=>query_fields.join(' '), 'facet.field' => ['name_s', 'model']})
    
    @total = solr_response["numFound"]
    @results = ModelInstance.find(solr_response['docs'].map{|d| d['id']})
  end

  def new
    @exhibit = Exhibit.new
  end

  def create
    @exhibit = Exhibit.new
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/).map{|f| Exhibit::Facet.new(:value=>f)}
    @exhibit.save
    redirect_to @exhibit
  end

  def update
    @exhibit = Exhibit.find(params[:id])
    @exhibit.title = params[:exhibit][:title]
    @exhibit.facets = params[:exhibit][:facets].split(/\s*,\s*/).map{|f| Exhibit::Facet.new(:value=>f)}
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
