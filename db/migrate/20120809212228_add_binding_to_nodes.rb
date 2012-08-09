class AddBindingToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :binding, :string
    add_index :nodes, :binding
  end
end
