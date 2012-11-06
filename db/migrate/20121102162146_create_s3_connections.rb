class CreateS3Connections < ActiveRecord::Migration
  def change
    create_table :s3_connections do |t|
      t.references :pool, :null=>false
      t.string     :access_key_id, :null=>false
      t.string     :secret_access_key, :null=>false
      t.integer    :max_file_size, :default=>10485760
      t.string     :acl, :default=>'public-read'
      t.timestamps
    end
  end
end
