desc 'Reindex all objects into solr'
task :reindex => :environment do
  # Drop all the models in solr
  Cocupu.solr.delete_by_query '*:*'

  Model.find(:all).each {|m| m.index}
  Cocupu.solr.commit
end

task :index => :environment do
  Model.find(:all).each {|m| m.index}
  Cocupu.solr.commit
end

desc "Run ci"
task :ci do 
  puts "Updating Solr config"
  puts %x[rails g cocupu:solr_conf -f]
  
  require 'jettywrapper'
  jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.join(Rails.root , 'jetty'), :startup_wait=>30 })
  
  puts "Starting Jetty"
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
      Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

