# This is a wrapper around an S3 Bucket giving it behaviors that Bindery needs/uses
class Bindery::Storage::S3::FileStore
  attr_accessor :bucket_name
  
  def initialize(params={})
    params = params.with_indifferent_access
    if params.has_key?(:bucket_name)
      @bucket_name = params[:bucket_name]
    end
  end
  
  def connection
    Bindery::Storage::S3.default_connection
  end
  
  def bucket
    if @bucket 
      return @bucket
    else
      return init_bucket(bucket_name)
    end
  end
  
  def init_bucket(bucket_name)
    conn = connection.send(:conn)
    conn.buckets.create(bucket_name, acl: :bucket_owner_full_control) unless conn.buckets[bucket_name].exists?
    @bucket = conn.buckets[bucket_name]
  end
  
end
