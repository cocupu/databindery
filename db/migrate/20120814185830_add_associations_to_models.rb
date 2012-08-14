class AddAssociationsToModels < ActiveRecord::Migration
  def change
    add_column :models, :associations, :text
  end
end
