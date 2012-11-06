class Chattel < ActiveRecord::Base
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true

  def spreadsheet?
    is_a? Bindery::Spreadsheet
  end

  def attachment
    File.open(file_name).read if id && File.readable?(file_name)
  end 

  def attach(file_content, content_type, original_filename)
    self.attachment_content_type = content_type
    self.attachment_file_name = original_filename
    self.attachment_extension = /\.([^.]+)$/.match(attachment_file_name)[1]

    store_file(file_content)
  end

  def file_name
    File.join(dir, file_key)
  end


  private

  def store_file(file_content)
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    #TODO avoid name collision
    stored = File.new(file_name, 'wb')
    stored.write file_content
    stored.close
  end

  def dir
    #Platform independant way of showing a File path. Empty String ('') means the root
    File.join('', 'tmp', 'cocupu', Rails.env)
  end

  def file_key
    raise "Can't make a key until the record is saved" unless id
    "#{id}.#{attachment_extension}"
  end

  def bucket_name
    "cocupu_#{Rails.env}"
  end

end
