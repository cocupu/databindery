class AddTokenAuthenticatableToLoginCredential < ActiveRecord::Migration
  def change
    add_column :login_credentials, :authentication_token, :string
    add_index :login_credentials, :authentication_token, :unique => true
  end
end
