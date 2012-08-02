class AddOwnerToSpreadsheet < ActiveRecord::Migration
  def change
    add_column :chattels, :owner_id, :integer
    add_foreign_key(:chattels, :identities, column: 'owner_id')
  end
end
