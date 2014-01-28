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

Bindery::Curator.instance.spawn_from_field(@ident, @pool, 26, "main_text_title_english", "texts", nil, "title_en", also_move:[{"main_text_title_tibetan"=>"title_tib"}], :delete_source_value=>false)
