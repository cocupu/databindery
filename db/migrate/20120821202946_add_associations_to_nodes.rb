class AddAssociationsToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :associations, :text
  end
end
