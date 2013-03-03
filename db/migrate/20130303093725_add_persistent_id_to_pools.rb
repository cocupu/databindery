class AddPersistentIdToPools < ActiveRecord::Migration
  def change
    add_column :pools, :persistent_id, :string
  end
end
