class AddTypeToSearchFilter < ActiveRecord::Migration
  def up
    change_table :search_filters do |t|
      t.string :filter_type, default: "GRANT"
    end
  end
  def down
    change_table :search_filters do |t|
      t.remove :filter_type
    end
  end
end
