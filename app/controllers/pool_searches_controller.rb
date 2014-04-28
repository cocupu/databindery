class PoolSearchesController < ApplicationController
  load_and_authorize_resource :identity, :find_by => :short_name
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource instance_name: :node, class: Node, find_by: :persistent_id, only: [:show]
  load_resource :model, through: :node, singleton: true, only: [:show]
  
  before_filter :set_perspective
  before_filter :load_configuration
  before_filter :load_model_for_grid

  include Blacklight::Controller
  def layout_name
    'application'
  end
  include Blacklight::Catalog
  include Bindery::AppliesPerspectives

  solr_search_params_logic << :add_pool_to_fq << :add_index_fields_to_qf << :apply_google_refine_query_params << :apply_datatables_params_to_solr_params << :ensure_model_filtered_for_grid << :apply_audience_filters

  # get search results from the solr index
  # Had to override the whole method (rather than using super) in order to add json support
  def index

    extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => t('blacklight.search.rss_feed') )
    extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => t('blacklight.search.atom_feed') )


    if params["queries"]
      do_refine_style_query
    else
      (@response, @document_list) = get_search_results
    end
    @filters = params[:f] || []

    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        @marshalled_results ||= marshall_nodes(@document_list.map{|d| d["id"]})
        if params["iDisplayStart"]
          render  json: datatables_response
        elsif params["nodesOnly"] || params["queries"]
          render  json: @marshalled_results
        else
          render json: json_response
        end
      end
    end
  end

  # Provides a pool overview with models, perspectives and facets
  def overview
    authorize! :show, @pool
    (@response, @document_list) = get_search_results(rows:0)
    respond_to do |format|
      format.json { render :json=>{id:@pool.id, models:@pool.models.as_json, perspectives:@pool.exhibits.as_json, facets:@response["facet_counts"]["facet_fields"], numFound:@response["response"]["numFound"] } }    
    end
  end
  
  
  protected

  # Given an Array of persistent_ids, loads the corresponding Nodes
  # @document_list [Array] Array of persistent_ids of Nodes that should be loaded
  def marshall_nodes(node_id_list)
    node_id_list.map{|nid| Node.find_by_persistent_id(nid)}
  end

  def json_response
    json_response = @response
    #json_response["docs"] = @response["response"]["docs"].map {|solr_doc| serialize_work_from_solr(solr_doc) }
    json_response["docs"] = @marshalled_results
    json_response
  end

  def load_configuration
    @blacklight_config = Blacklight::Configuration.new
    @blacklight_config.configure do |config|
      ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
      config.default_solr_params = { 
        :qt => 'search',
        :fl => '*', 
        :rows => 10 
      }

      ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
      ## parameters included in the Blacklight-jetty document requestHandler.
      #
      #config.default_document_solr_params = {
      #  :qt => 'document',
      #  ## These are hard-coded in the blacklight 'document' requestHandler
      #  # :fl => '*',
      #  # :rows => 1
      #  # :q => '{!raw f=id v=$id}' 
      #}

      # solr field configuration for search results/index views
      config.index.show_link = 'title'
      config.index.record_display_type = 'model_name'

      # solr field configuration for document/show views
      config.show.html_title = 'title'
      config.show.heading = 'title'
      config.show.display_type = 'model_name'

      # solr fields that will be treated as facets by the blacklight application
      #   The ordering of the field names is the order of the display
      #
      # Setting a limit will trigger Blacklight's 'more' facet values link.
      # * If left unset, then all facet values returned by solr will be displayed.
      # * If set to an integer, then "f.somefield.facet.limit" will be added to
      # solr request, with actual solr request being +1 your configured limit --
      # you configure the number of items you actually want _displayed_ in a page.    
      # * If set to 'true', then no additional parameters will be sent to solr,
      # but any 'sniffed' request limit parameters will be used for paging, with
      # paging at requested limit -1. Can sniff from facet.limit or 
      # f.specific_field.facet.limit solr request params. This 'true' config
      # can be used if you set limits in :default_solr_params, or as defaults
      # on the solr side in the request handler itself. Request handler defaults
      # sniffing requires solr requests to be made with "echoParams=all", for
      # app code to actually have it echo'd back to see it.  
      #
      # :show may be set to false if you don't want the facet to be drawn in the 
      # facet bar
      exhibit.facets.uniq.each do |key|
        if key == "model_name"
          config.add_facet_field Node.solr_name(key, type: 'facet'), :label => "Model", limit: 10
        else
          config.add_facet_field Node.solr_name(key, type: 'facet'), :label => key.humanize, limit: 10
        end
      end


      # Have BL send all facet field names to Solr, which has been the default
      # previously. Simply remove these lines if you'd rather use Solr request
      # handler defaults, or have no facets.
      config.add_facet_fields_to_solr_request!

      # solr fields to be displayed in the index (search results) view
      #   The ordering of the field names is the order of the display 
      exhibit.index_fields.uniq.each do |f|
        if f == "model_name"
          config.add_index_field Node.solr_name(f, type: 'facet'), :label => "Model"
        else
          config.add_index_field Node.solr_name(f), :label => f.humanize+':' 
        end
      end
      # query_fields = exhibit.pool.models.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
      #solr_parameters[:qf] = query_fields + ["pool"]

      # solr fields to be displayed in the show (single result) view
      #   The ordering of the field names is the order of the display 
      exhibit.index_fields.uniq.each do |f|
        if f == "model_name"
          config.add_show_field Node.solr_name(f, type: 'facet'), :label => "Model"
        else
          config.add_show_field Node.solr_name(f), :label => f.humanize+':' 
        end
      end

      # "fielded" search configuration. Used by pulldown among other places.
      # For supported keys in hash, see rdoc for Blacklight::SearchFields
      #
      # Search fields will inherit the :qt solr request handler from
      # config[:default_solr_parameters], OR can specify a different one
      # with a :qt key/value. Below examples inherit, except for subject
      # that specifies the same :qt as default for our own internal
      # testing purposes.
      #
      # The :key is what will be used to identify this BL search field internally,
      # as well as in URLs -- so changing it after deployment may break bookmarked
      # urls.  A display label will be automatically calculated from the :key,
      # or can be specified manually to be different. 

      # This one uses all the defaults set by the solr request handler. Which
      # solr request handler? The one set in config[:default_solr_parameters][:qt],
      # since we aren't specifying it otherwise. 
      
      config.add_search_field 'all_fields', :label => 'All Fields'
      
      # "sort results by" select (pulldown)
      # label in pulldown is followed by the name of the SOLR field to sort by and
      # whether the sort is ascending or descending (it must be asc or desc
      # except in the relevancy case).
      config.add_sort_field 'score desc, title asc', :label => 'relevance'
      config.add_sort_field 'timestamp desc, title asc', :label => 'recently modified'
      config.add_sort_field 'title asc', :label => 'title'

      
      # If there are more than this many search results, no spelling ("did you 
      # mean") suggestion is offered.
      config.spell_max = 5
    end
  end

  def add_pool_to_fq(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "pool:#{exhibit.pool_id}"

  end

  # The fields set in qf are the ones that we query on. A pretty good default is to use the fields we display.
  def add_index_fields_to_qf(solr_parameters, user_parameters)
    solr_parameters[:qf] ||= []
    solr_parameters[:qf] << 'title'
    blacklight_config.index_fields.each do |field_name, obj|
      solr_parameters[:qf] << field_name
    end
  end

  # If @google_refine_query_params is set, applies those parameters to the solr query params
  # @example Sample Google Refine Query
  #   "queries" => {
  #     "q1" => {
  #      "query" => "Ford Taurus",
  #          "limit" => 3,
  #          "type" => "/automotive/model",
  #          "type_strict" => "any",
  #          "properties" => [
  #          { "p" => "year", "v" => 2009 },
  #          { "pid" => "/automotive/model/make" , "v" => "/en/ford" }
  #          ]
  #    },{
  #     "q2" => {
  #        "query"=>"Dodge Neon"
  #     }
  #    }
  def apply_google_refine_query_params(solr_parameters, user_parameters)
    unless @google_refine_query_params.nil?
      query_params = @google_refine_query_params
      #"type_strict" => "any"
      solr_parameters["q"] = query_params["query"]
      solr_parameters["rows"] =  query_params["limit"] unless query_params["limit"].nil?
      if query_params["type"] # && query_params["type_strict"] == "should"
        solr_parameters[:fq] << "+#{Node.solr_name("model_name", type:"facet")}:\"#{query_params["type"]}\""
      end
      # Examples of property_query values
      #{ "p" => "year", "v" => 2009 },
      #{ "pid" => "/automotive/model/make" , "v" => "/en/ford" }
      query_params["properties"] ||= []
      query_params["properties"].each do |property_query|

        if property_query["p"]
          property_name =  property_query["p"]
        elsif property_query["pid"]
          property_name = @pool.all_fields.select {|f| f["uri"] == property_query["pid"]}.first["name"]
        end
        # model_id is stored in the "model" solr field.  Map the query accordingly.
        if property_name == "model_id"
          property_name = "model"
        end
        solr_parameters[:fq] << "+#{Node.solr_name(property_name)}:\"#{property_query["v"]}\"" unless (property_name.nil? || property_query["v"].nil?)
      end
      solr_parameters[:fl] = "*,score"
    end
  end


  #
  # DataTables Support
  #

  def apply_datatables_params_to_solr_params(solr_parameters, user_parameters)
    unless user_parameters["iDisplayStart"].nil?
      solr_parameters[:page] = user_parameters["iDisplayStart"].to_i/user_parameters["iDisplayLength"].to_i
      solr_parameters[:rows] = user_parameters["iDisplayLength"].to_i
      solr_parameters[:q] = user_parameters["sSearch"]
      # bRegex, individual column filters []bSearchable_(int),sSearch_(int),bRegex_(int), bSortable_(int)	]
      #iSortCol_(int)
      #sSortDir_(int)
      if user_parameters["iSortingCols"]
        number_of_sort_columns = user_parameters["iSortingCols"].to_i
        column_fields = @model_for_grid.ordered_fields_and_associations
        column_sorts = []
        (1..number_of_sort_columns).each do |index|
          sort_column_number = user_parameters["iSortCol_#{index}"].to_i
          sort_column_direction = user_parameters["sSortDir_#{index}"] == "desc" ? "desc" : "asc"
          field_name = Node.solr_name(column_fields[sort_column_number][:code])
          column_sorts << "#{field_name} #{sort_column_direction}"
        end
        # Disabled until Node & Model handle multivalue vs. single-value fields more carefully & index single-value fields accordingly in solr.
        # solr_parameters[:sort] = column_sorts.join(", ")
      end
      # mDataProp
      # sEcho  -- use this to pass faceting info...
    end
  end

  def datatables_response
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @response.total,
        iTotalDisplayRecords: @response.total,
        aaData: @marshalled_results.map {|n| [view_context.link_to("Edit", identity_pool_solr_document_path(@identity, @pool, n.persistent_id))].concat(serialize_node_as_json_row(n)) }
    }
  end

  def serialize_node_as_json_row(node)
    json_row = []
    node.model.fields.each do |model_field|
      json_row << node.data[ model_field[:code] ]
    end
    assoc = node.associations_for_json
    node.model.associations.each do |model_assoc|
      assoc_array = node.associations_for_json[ model_assoc[:name] ]
      link_array = []
      assoc_array.each do |assoc|
        link_array << view_context.link_to(assoc[:title], identity_pool_solr_document_path(@identity, @pool, assoc["persistent_id"]))
      end
      #json_row << node.associations_for_json[ model_assoc[:name] ]
      json_row << link_array
    end
    json_row
  end

  # Load the selected model for use in generating grid column sorting, etc.
  def load_model_for_grid
    if params["model_id"]
      @model_for_grid = @pool.models.find(params["model_id"])
    else
      #if (params[:format].nil? || params[:format] == "html") && params["view"] != "browse"
      if params["view"] == "grid"
        @model_for_grid = @pool.models.first
      end
    end
  end

  def ensure_model_filtered_for_grid(solr_parameters, user_parameters)
    unless @model_for_grid.nil?
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "model:#{@model_for_grid.id}"
    end
  end

  def apply_audience_filters(solr_parameters, user_parameters)
    unless can? :edit, @pool
      @pool.apply_solr_params_for_identity(current_identity, solr_parameters, user_parameters)
    end
  end

  #
  # Google Refine Support
  #
  def do_refine_style_query
    @marshalled_results ||= {}
    params["queries"].each_pair do |query_name, multi_query_params|
      @google_refine_query_params = multi_query_params
      (@response, @document_list) = get_search_results
      # Marshall nodes if requested.  Default to returning json based on Google Refine Resolver API spec
      if params["marshall_nodes"]
        @marshalled_results[query_name] = {result: @document_list.map {|doc| Node.find_by_persistent_id(doc['id'])}}
      else
        @marshalled_results[query_name] = {result: @document_list.map {|doc| {id:doc["id"], name:doc["title"], type:[doc["model_name"]], score:doc["score"], match:true }}}
      end
      @marshalled_results[query_name].merge!(@response["response"].except("docs"))
    end
  end

end
