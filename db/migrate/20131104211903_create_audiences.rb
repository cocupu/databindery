class CreateAudiences < ActiveRecord::Migration
  def change
    create_table :audiences do |t|
      t.string :name
      t.text :description
      t.integer :position
      t.integer :audience_category_id

      t.timestamps
    end
  end
end
