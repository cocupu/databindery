module Bindery::Storage::S3
  def self.default_connection
    @conn ||= S3Connection.new(:access_key_id => AWS.config.access_key_id,
                            :secret_access_key => AWS.config.secret_access_key)
  end
end
