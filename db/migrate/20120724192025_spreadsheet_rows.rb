class SpreadsheetRows < ActiveRecord::Migration
  def change
    create_table :spreadsheet_rows do |t|
      t.integer :row_number
      t.integer :worksheet_id
      t.text :values
      t.timestamps
    end
  end
end
