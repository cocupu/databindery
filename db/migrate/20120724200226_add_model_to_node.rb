class AddModelToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :model_id, :integer
    add_index :nodes, :model_id
  end
end
