class AddOrderToWorksheet < ActiveRecord::Migration
  def change
    add_column :worksheets, :order, :integer
  end
end
