describe 'Reindex all objects into solr'
task :reindex => :environment do
  Model.find(:all).each {|m| m.index}
end

