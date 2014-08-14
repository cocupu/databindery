class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.string :type
      t.string :uri
      t.string :code
      t.string :label
      t.boolean :multivalue

      t.timestamps
    end
    create_table :fields_models, id: false do |t|
      t.integer :field_id
      t.integer :model_id
    end
    Model.all.each do |m|
      m.update_attributes(fields_attributes: m[:fields])
    end
    add_column :search_filters, :field_id, :integer
  end
end
