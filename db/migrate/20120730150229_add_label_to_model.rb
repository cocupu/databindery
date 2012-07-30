class AddLabelToModel < ActiveRecord::Migration
  def change
    add_column :models, :label, :string
  end
end
