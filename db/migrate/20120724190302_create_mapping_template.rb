class CreateMappingTemplate < ActiveRecord::Migration
  def change
    create_table :mapping_templates do |t|
      t.integer :row_start
      t.text :models
      t.timestamps
    end
  end
end
