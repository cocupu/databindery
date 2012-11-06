class AddCodeToModel < ActiveRecord::Migration
  def change
    add_column :models, :code, :string
    add_index :models, :code, :unique=>true
  end
end
