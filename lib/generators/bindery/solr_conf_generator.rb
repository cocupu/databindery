# -*- encoding : utf-8 -*-
module Bindery
  class SolrConf < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    argument :target_path, :type=>:string, :default => "jetty/solr"
    
    desc """ 
Generate solr config files solrconfig.xml and schema.xml
to directory you specify. (default current dir).  

Conf files generated are set up to work with out-of-the-box default 
blacklight.

You might want to put them into a solr setup, or you might just
want to look at them.   

"""
    
    # this generator used by test jetty generator too. 
    def solr_conf_files
      copy_file "solr_conf/solr.xml", File.expand_path("./solr.xml", target_path)
      ['development', 'test'].each do |core|
        conf_path = "#{target_path}/#{core}-core/conf"
        copy_file "solr_conf/schema.xml", File.expand_path("./schema.xml", conf_path)
        copy_file "solr_conf/solrconfig.xml", File.expand_path("./solrconfig.xml", conf_path)
      end
    end
  end
end
