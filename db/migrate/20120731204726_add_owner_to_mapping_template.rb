class AddOwnerToMappingTemplate < ActiveRecord::Migration
  def change
    add_column :mapping_templates, :identity_id, :integer
    add_index :mapping_templates, :identity_id
    add_foreign_key(:mapping_templates, :identities)
  end
end
