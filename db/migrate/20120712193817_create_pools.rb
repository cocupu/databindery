class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.string :name
      t.integer :owner_id
      t.timestamps
    end
    add_foreign_key(:pools, :identities, column: 'owner_id')
  end
end
