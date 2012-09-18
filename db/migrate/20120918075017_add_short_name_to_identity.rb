class AddShortNameToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :short_name, :string
    add_index :identities, :short_name, :unique=>true
  end
end
