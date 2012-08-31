class AddShortNameAndDescriptionToPools < ActiveRecord::Migration
  def change
    add_column :pools, :short_name, :string
    add_column :pools, :description, :text
    add_index :pools, :short_name, :unique=>true
  end
end
