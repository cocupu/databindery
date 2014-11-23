class AddLabelFieldToModels < ActiveRecord::Migration
  def up
    add_column :models, :label_field_id, :integer
    #add_foreign_key(:models, :fields)
    Model.all.each do |m|
      if m.label && !m.fields.where(code:m.label).empty?
        m.label_field = m.fields.where(code:m.label).first
        m.save
      end
    end
  end
  def down
    remove_column :models, :label_field_id
  end

end
