class JoinIdentitiesAndAudiences < ActiveRecord::Migration
  def up
    create_table :audiences_identities do |t|
      t.belongs_to :identity
      t.belongs_to :audience
    end
  end

  def down
    drop_table :audiences_identities
  end
end
