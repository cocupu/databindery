# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Blacklight::SolrHelper do
  def params
    {}
  end

  def blacklight_config
    @config ||= Cocupu::Config.new
  end
  
  def blacklight_config=(config)
    @config = config
  end

  include Blacklight::SolrHelper

  describe "#add_paging_to_solr" do
    it "should copy :page from user_params to solr_params" do
      solr_params = {:rows=>10} #rows is typically set by Cocupu::Config
      add_paging_to_solr(solr_params, {:page=>4})
      solr_params.should == {:page => 4, :rows=>10, :start=>30}
    end
  end
end


