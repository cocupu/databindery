class AddPoolToModel < ActiveRecord::Migration
  def change
    add_column :models, :pool_id, :integer
    Model.all.each do |m|
      m.pool = m.owner.pools.first
      m.save!
    end
    add_foreign_key(:models, :pools)
  end
end
