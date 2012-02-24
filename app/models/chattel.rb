class Chattel
  include Ripple::Document
  alias_method :id, :key

  def spreadsheet?
    is_a? Cocupu::Spreadsheet
  end

  property :attachment_content_type, String
  property :attachment_file_name, String
  property :attachment_extension, String


  def attachment
    #call .url_for(:read) (public signed), .public_url (unsigned), or .read() on this object
    s3 = AWS::S3.new
    s3.buckets[bucket_name].objects[file_key]
  end 

  def attachment= file
    self.save if new?  ## Generate a key
    self.attachment_content_type = file.content_type
    self.attachment_file_name = file.original_filename
    self.attachment_extension = /\.([^.]+)$/.match(attachment_file_name)[1]

    # get an instance of the S3 interface using the default configuration
    s3 = AWS::S3.new

    # create a bucket
    b = s3.buckets.create(bucket_name)

    # upload a file
    o = b.objects[file_key]
    o.write(file.read, :content_type=> attachment_content_type)
  end

  private

  def file_key
    "#{key}.#{attachment_extension}"
  end

  def bucket_name
    "cocupu_#{Rails.env}"
  end

end
