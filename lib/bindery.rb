module Bindery
  extend ActiveSupport::Autoload
  autoload :SeedDataImporter

  def self.solr
    @solr ||=  RSolr.connect(solr_config)
  end

  def self.solr_file
    "#{::Rails.root.to_s}/config/solr.yml"
  end

  def self.solr_config
    @solr_config ||= begin
        raise "You are missing a solr configuration file: #{solr_file}. Have you run \"rails generate cocupu:jetty\"?" unless File.exists?(solr_file) 

        begin
          @solr_erb = ERB.new(IO.read(solr_file)).result(binding)
        rescue Exception => e
          raise("solr.yml was found, but could not be parsed with ERB. \n#{$!.inspect}")
        end
        begin
          solr_config = YAML::load(@solr_erb)
        rescue StandardError => e
          raise("solr.yml was found, but could not be parsed.\n")
        end

        raise "The #{::Rails.env} environment settings were not found in the solr.yml config" unless solr_config[::Rails.env]
        solr_config[::Rails.env].symbolize_keys
      end
    @solr_config
  end

  # Documents is a single solr document or array of solr documents
  def self.index(documents)
    documents = Array.wrap(documents)
    documents.each do |doc|
      solr.add doc
    end
    Bindery.solr.commit
  end

  def self.clear_index
    raw_results = Bindery.solr.get 'select', :params => {:q => '{!lucene}*:*', :fl=>'id', :qt=>'document', :rows=>100}
    Bindery.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
    Bindery.solr.commit
  end
end

