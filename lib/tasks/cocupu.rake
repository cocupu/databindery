describe 'Reindex all objects into solr'
task :reindex => :environment do
  Model.find(:all).each {|m| m.index}
end

#UGH: https://github.com/rails/rails/pull/2948#issuecomment-5832017
  class Rake::Task
    def overwrite(&block)
      @actions.clear
      enhance(&block)
    end
  end

  Rake::Task['db:test:prepare'].overwrite do
    # We don't want to run migrations or load the schema!!!
  end
