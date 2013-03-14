class AddAllowFileBindingsToModels < ActiveRecord::Migration
  def change
    add_column :models, :allow_file_bindings, :boolean, default: true
  end
end
