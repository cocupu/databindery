class AddIndexFieldsToExhibit < ActiveRecord::Migration
  def change
    add_column :exhibits, :index_fields, :text
  end
end
