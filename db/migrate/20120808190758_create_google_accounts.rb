class CreateGoogleAccounts < ActiveRecord::Migration
  def change
    create_table :google_accounts do |t|
      t.integer :owner_id
      t.string :profile_id
      t.string :email
      t.string :refresh_token
      t.timestamps
    end
    add_foreign_key(:google_accounts, :identities, column: 'owner_id')
  end
end
