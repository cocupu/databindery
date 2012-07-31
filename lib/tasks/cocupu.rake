describe 'Reindex all objects into solr'
task :reindex => :environment do
  # Drop all the models in solr
  Cocupu.solr.delete_by_query '*:*'

  Model.find(:all).each {|m| m.index}
  Cocupu.solr.commit
end

