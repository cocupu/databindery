module Cocupu
  module Search
    extend ActiveSupport::Concern
    include Blacklight::SolrHelper

    private

    # def blacklight_config 
    #   @config ||= Cocupu::Config.new
    # end
  end
end
