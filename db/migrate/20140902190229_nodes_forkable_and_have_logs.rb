class NodesForkableAndHaveLogs < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.boolean :is_fork, default: false
      t.string :log
    end
  end
end
