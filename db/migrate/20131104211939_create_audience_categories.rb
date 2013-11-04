class CreateAudienceCategories < ActiveRecord::Migration
  def change
    create_table :audience_categories do |t|
      t.integer :pool_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
