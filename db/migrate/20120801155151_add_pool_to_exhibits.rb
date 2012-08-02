class AddPoolToExhibits < ActiveRecord::Migration
  def change
    add_column :exhibits, :pool_id, :integer
    add_foreign_key(:exhibits, :pools)
  end
end
