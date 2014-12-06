module Bindery
  class SeedDataImporter
    include Singleton

    def seed_identity
      @seed_identity = Identity.find_or_create_by(name:"DataBindery Seed Curator", short_name:"bindery_seed_curator")
    end

    def seed_pool
      @seed_pool = Pool.find_or_create_by(name:"Pullahari RDI Shrine Images", short_name:"pullahari_rdi_shrine_images", owner:seed_identity, description:"Images from the Rigpe Dorje Institute Shrine Hall at Pullahari Monastery in Kathmandu, Nepal.")
    end

    def import_data(path_to_json, model, pool)
      file = File.open(path_to_json)
      data_entries = []
      file.each_line do |line|
        begin
          data_entries << JSON.parse(line)
        rescue => e
          puts "Bad line: "+ line
        end
      end
      converted_data = data_entries.map {|entry| model.convert_data_field_codes_to_id_strings(entry) }
      puts ::Node.bulk_import_records(converted_data, pool, model)
    end

  end
end
