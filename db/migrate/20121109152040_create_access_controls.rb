class CreateAccessControls < ActiveRecord::Migration
  def change
    create_table :access_controls do |t|
      t.references :pool
      t.references :identity
      t.string :access
      t.timestamps
    end
  end
end
