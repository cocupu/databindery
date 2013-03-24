class AddSpawnedFromToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :spawned_from_node_id, :integer
    add_column :nodes, :spawned_from_datum_id, :integer  
  end
end
