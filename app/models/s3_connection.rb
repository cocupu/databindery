class S3Connection < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :pool

  validates :access_key_id, presence: true
  validates :secret_access_key, presence: true


  def put(bucket_name, file_name, file)
    bucket = conn.buckets[bucket_name]
    bucket = conn.buckets.create(bucket_name) unless bucket.exists?
    bucket.objects[file_name].write(file)
  end

  def get(bucket, file_name)
    conn.buckets[bucket].objects[file_name]
  end
  
  def create_bucket(bucket)
    conn.buckets.create(bucket)
    conn.buckets[bucket]
  end
  
  # Exclude secret_access_key from json output.
  def as_json(options={})
    options[:except] ||= :secret_access_key
    super(options)
  end
  
  private 
  def conn
    @conn ||= AWS::S3.new(:access_key_id => access_key_id,
                          :secret_access_key => secret_access_key)
  end
end
