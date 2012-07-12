class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :name
      t.references :login_credential

      t.timestamps
    end
    add_foreign_key(:identities, :login_credentials)
  end

end
