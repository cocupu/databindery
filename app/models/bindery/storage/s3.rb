module Bindery::Storage::S3
  def self.default_connection
    @conn ||= S3Connection.new(:access_key_id => AWS.config.access_key_id,
                            :secret_access_key => AWS.config.secret_access_key)
  end
  
  def self.key_from_filepath(filepath, options)
    key = CGI::unescape(filepath)
    if options.has_key?(:bucket)
      key.gsub!(options[:bucket], "")
    end
    # Shop off all preceding slashes
    key.gsub!(/^[\/]*/, "")
    return key
  end
end
