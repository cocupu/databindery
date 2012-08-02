class AddOwnerToModel < ActiveRecord::Migration
  def change
    add_column :models, :identity_id, :integer
    add_index :models, :identity_id
    add_foreign_key(:models, :identities)
  end
end
