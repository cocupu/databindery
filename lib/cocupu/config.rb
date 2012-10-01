module Cocupu
  class Config

    def search_fields
      {}
    end

    def default_solr_params
      { :rows=>10, 'wt'=>:ruby}
    end

    def facet_fields
      {}
    end

    def max_per_page
      30
    end

    def default_sort_field
    end

    def sort_fields
      {}
    end
  end
end
