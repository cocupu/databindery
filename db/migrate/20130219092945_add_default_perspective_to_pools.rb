class AddDefaultPerspectiveToPools < ActiveRecord::Migration
  def change
    add_column :pools, :chosen_default_perspective_id, :integer
    add_foreign_key(:pools, :exhibits, column: 'chosen_default_perspective_id')    
  end
end