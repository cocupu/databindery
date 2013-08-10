class AddExhibitToSearchFilter < ActiveRecord::Migration
  def change
    add_column :search_filters, :exhibit_id, :integer
    add_foreign_key(:search_filters, :exhibits)
  end
end
