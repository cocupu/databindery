# Adds missing fields to  Model.file_entity
file_entity_model = Model.file_entity
[{'code' => 'file_name', 'type' => 'TextField', 'name' => "Filename"}, {'code' => 'bucket', 'type' => 'TextField', 'name' => "Bucket"},{'code' => 'storage_location_id', 'type' => 'TextField', 'name' => "Storage Location ID"},{'code' => 'file_entity_type', 'type' => 'TextField', 'name' => "Type of File"},{'code' => 'content-type', 'type' => 'TextField', 'name' => "Content Type"},{'code' => 'mime_type', 'type' => 'TextField', 'name' => "Mime Type"},{'code' => 'file_size', 'type' => 'IntegerField', 'name' => "File Size"}].each do |field_attributes|
  if file_entity_model.fields.where(code:field_attributes['code']).empty?
    file_entity_model.fields.create(field_attributes)
  end
  file_entity_model.label_field = file_entity_model.fields.where(code:'file_name').first
end
file_entity_model.save