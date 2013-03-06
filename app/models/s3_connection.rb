class S3Connection < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :pool

  validates :access_key_id, presence: true
  validates :secret_access_key, presence: true

  def bucket(bucket_name)
    bucket = conn.buckets[bucket_name]
  end
  
  def ensure_bucket_initialized(bucket_name)
    bucket = conn.buckets[bucket_name]
    bucket = conn.buckets.create(bucket_name, :acl => :private) unless bucket.exists?
    return bucket
  end

  def ensure_cors_for_uploads(bucket_name)
    bucket = ensure_bucket_initialized(bucket_name)
    allowed_origins = bucket.cors.select{|c| c.allowed_methods.include?("POST")}.map{|c| c.allowed_origins}.flatten
    unless allowed_origins.include?("*") || allowed_origins.include?(Socket.gethostname)
      rule = AWS::S3::CORSRule.new(allowed_methods:["PUT","POST", "GET"], allowed_origins:[Socket.gethostname], allowed_headers:["*"])
      bucket.cors.set(rule)
    end
  end
  
  def put(bucket_name, file_name, file)
    bucket = ensure_bucket_initialized(bucket_name)
    bucket.objects[file_name].write(file)
  end

  def get(bucket, file_name)
    conn.buckets[bucket].objects[file_name]
  end

  private 
  def conn
    @conn ||= AWS::S3.new(:access_key_id => access_key_id,
                          :secret_access_key => secret_access_key)
  end
end
