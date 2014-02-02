b = Cocupu.start(@ident.login_credential.email, 'notblank', 8989)

ident_name = "matt"
pool_name = "foo"
source_model = Cocupu::Model.load(19)

# create the destination model

  dest_model = Cocupu::Model.new({identity:ident_name, pool:pool_name, 'name'=>"Car", "allow_file_bindings"=>"false"})
  dest_model.save

# add association to source model
source_model.associations << {"type"=>"Has One","name"=>"submitted_by", "label"=>"Submitted By","references"=>dest_model.id}

source_model_id = 19
dest_model

# spawn from field
Cocupu::Curator.spawn_from_field(ident_name, pool_name, source_model.id, "submitted_by", "submitted_by", dest_model.id, "full_name", delete_source_value:true)


@ident = Identity.find_by_short_name("matt")
@pool = @ident.pools.where(short_name:"sample1").first
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 26, "submitted_by", "creator", nil, "full_name", :delete_source_value=>false)
# the line above created model 24.  re-using that model for the next line
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 26, "collection_owner", "collection_owner", 27, "full_name", :delete_source_value=>false)
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 26, "program_location", "location", 25, "name", :delete_source_value=>false)
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 26, "collection_location", "collection_location", 25, "name", :delete_source_value=>false)

Bindery::Curator.instance.spawn_from_field(@ident, @pool, 37, "main_text_title_english", "texts", nil, "title_en", also_move:[{"main_text_title_tibetan"=>"title_tib"}], :delete_source_value=>false)


@ident = Identity.find_by_short_name("flyingzumwalt")
@pool = @ident.pools.where(short_name:"sample_pool1").first

# Programs
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 36, "program_title_english", "program", nil, "name", also_copy:["date_from", "date_to", "program_location", "restricted", "teacher", "main_text_title_english", "main_text_title_tibetan"], :delete_source_value=>false)
# ... get program model id
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 37, "program_location", "location", nil, "name", :delete_source_value=>false)
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 36, "collection_location", "collection_location", 38, "name", :delete_source_value=>false)

# PEOPLE
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 36, "submitted_by", "creator", nil, "full_name", :delete_source_value=>false)
Bindery::Curator.instance.spawn_from_field(@ident, @pool, 36, "collection_owner", "collection_owner", person_model_id, "full_name", :delete_source_value=>false)


to_remove = %w(program_title_english program_location collection_location submitted_by collection_owner)+["date_from", "date_to", "program_location", "restricted", "teacher", "main_text_title_english", "main_text_title_tibetan"]
m.fields.delete_if {|f| to_remove.include?(f[:code])}

%w(1ab48ce0-6c3b-0131-1e93-7cd1c3f26451 1a612a20-6c3b-0131-1e92-7cd1c3f26451 1a0bce00-6c3b-0131-1e91-7cd1c3f26451 19ba2530-6c3b-0131-1e90-7cd1c3f26451).each {|pid| Node.find_by_persistent_id(pid).delete}

to_remove = ["program_location", "title_tib", "main_text_title_tibetan"]
