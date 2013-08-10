class CreateSearchFilters < ActiveRecord::Migration
  def change
    create_table :search_filters do |t|
      t.string :field_name
      t.string :operator
      t.text :values

      t.timestamps
    end
  end
end
