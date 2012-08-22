module Cocupu
  module Search
    extend ActiveSupport::Concern
    include Blacklight::SolrHelper

    private

    def blacklight_config 
      @config ||= Cocupu::Config.new
    end


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
end
