class CreateChangeSets < ActiveRecord::Migration
  def self.down
    drop_table :change_sets
  end
  def self.up
    create_table :change_sets do |t|
      t.hstore :data
      t.references :pool
      t.references :identity
      t.integer :parent_id
      t.timestamps
    end
    add_foreign_key(:change_sets, :pools)
    add_foreign_key(:change_sets, :identities)
    add_foreign_key(:change_sets, :change_sets, column: 'parent_id')
    execute'CREATE INDEX change_sets_gist_data ON change_sets USING GIST(data);'
  end
end
