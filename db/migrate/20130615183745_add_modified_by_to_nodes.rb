class AddModifiedByToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :modified_by_id, :integer
  end
end
