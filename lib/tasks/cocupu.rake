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

namespace :spec do

  desc "test the client"
  task :client do
    pid = fork do
      exec("unicorn_rails -p 8888 --env test")
    end
    RSpec::Core::RakeTask.new(:client_runner) do |t|
        t.rspec_opts = ["--colour", "--format", "progress"]
        t.verbose = true
        #t.rspec_opts += ["-r #{File.expand_path(File.join(::Rails.root, 'config', 'environment'))}"]
        t.pattern = 'spec/client/client_spec.rb'
    end
    begin
      Rake::Task["client_runner"].invoke
    # rescue Exception => e
    #   puts "something went wrong #{e}"
    ensure
      puts "Stopping server"
      Process.kill('TERM', pid)
      puts "stopped"
      sleep(1)
    end

  end
end
