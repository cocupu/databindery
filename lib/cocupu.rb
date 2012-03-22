module Cocupu  
  def self.solr
    @solr ||=  RSolr.connect(solr_config)
  end

  def self.solr_file
    "#{::Rails.root.to_s}/config/solr.yml"
  end

  def self.solr_config
    @solr_config ||= begin
        raise "You are missing a solr configuration file: #{solr_file}. Have you run \"rails generate cocupu:jetty\"?" unless File.exists?(solr_file) 
        solr_config = YAML::load(File.open(solr_file))
        raise "The #{::Rails.env} environment settings were not found in the solr.yml config" unless solr_config[::Rails.env]
        solr_config[::Rails.env].symbolize_keys
      end
    @solr_config
  end

  # Documents is a single solr document or array of solr documents
  def self.index(documents)
    documents = [documents] unless documents.respond_to? :to_enum
    documents.each do |doc|
      solr.add doc
    end
    Cocupu.solr.commit
  end
end

