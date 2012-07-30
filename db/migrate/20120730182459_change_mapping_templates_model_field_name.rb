class ChangeMappingTemplatesModelFieldName < ActiveRecord::Migration
  def change
    rename_column :mapping_templates, :models, :model_mappings
  end
end
