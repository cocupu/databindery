class AddContentTypeToFileEntity < ActiveRecord::Migration
  def up
    file_entity_model = Model.file_entity
    file_entity_model.fields << {'code' => 'content_type', 'type' => 'textfield', 'name' => "Content Type" }.with_indifferent_access
    file_entity_model.save
  end

  def down
    file_entity_model = Model.file_entity
    file_entity_model.fields.delete_if {|f| f["code"] == "content_type"}
    file_entity_model.save
  end
end
