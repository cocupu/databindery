class Worksheets < ActiveRecord::Migration
  def change
    create_table :worksheets do |t|
      t.string :name
      t.integer :spreadsheet_id
      t.timestamps
    end
  end
end
