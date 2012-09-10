class AddPoolToMappingTemplate < ActiveRecord::Migration
  def change
    add_column :mapping_templates, :pool_id, :integer
    add_foreign_key(:mapping_templates, :pools)
  end
end
