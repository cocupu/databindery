class AddHeadToPool < ActiveRecord::Migration
  def self.down
    remove_column :pools,  :head_id
  end
  def self.up
    change_table :pools do |t|
      t.integer :head_id
      t.foreign_key :change_sets, column: 'head_id'
    end
  end
end
