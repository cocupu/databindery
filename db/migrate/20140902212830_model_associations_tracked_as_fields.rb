class ModelAssociationsTrackedAsFields < ActiveRecord::Migration
  def change
    change_table :fields do |t|
      t.integer :references
    end
    Model.all.each do |m|
      m[:associations].each do |assoc|
        assoc[:type] = "OrderedListAssociation"
        m.associations.create(assoc)
      end
    end
  end
end
