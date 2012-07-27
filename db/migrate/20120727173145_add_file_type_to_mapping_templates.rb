class AddFileTypeToMappingTemplates < ActiveRecord::Migration
  def change
    add_column :mapping_templates, :file_type, :string
  end
end
