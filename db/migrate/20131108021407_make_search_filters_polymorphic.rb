class MakeSearchFiltersPolymorphic < ActiveRecord::Migration
  def up
    # Removing the old foreign_key constraint
    remove_foreign_key(:search_filters, :exhibits)
    change_table :search_filters do |t|
      t.rename :exhibit_id, :filterable_id
      t.string :filterable_type
      SearchFilter.update_all(filterable_type: 'Exhibit')
      # Could have used this more compact notation if :exhibit_id wasn't already in use in prod.
      #t.belongs_to :filterable, polymorphic: true
    end
    add_index :search_filters, [:filterable_id, :filterable_type]
  end
  def down
    change_table :search_filters do |t|
      t.rename :filterable_id, :exhibit_id
      t.remove :filterable_type
    end
    add_foreign_key(:search_filters, :exhibits)
  end
end
