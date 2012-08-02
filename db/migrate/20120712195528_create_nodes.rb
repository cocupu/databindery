class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      ## The id of this table is the version_id
      t.text :data
      t.string :persistent_id
      t.string :parent_id
      t.references :pool
      t.references :identity
      t.timestamps
    end
    add_foreign_key(:nodes, :pools)
    add_foreign_key(:nodes, :identities)
  end
end
