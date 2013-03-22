module FileEntity
  
  # Creates a FileEntity corresponding to a remote file with the given characteristics.
  # Required parameters:
  #   pool <Pool>
  #   binding <String> that is the URI uniquely identifying the remote file
  # Currently Assumes:
  #   * the remote file is in Amazon S3
  #   * the S3 object is in the given Pool's default bucket
  # @example
  #   file_entity = FileEntity.register(my_pool, :data=>{"filepath"=>"/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg", "filename"=>"DSC_0549-3.jpg", "filesize"=>"471990", "filetype"=>"image/jpeg", "binding"=>"https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"})
  def self.register(pool, opts={})
    opts = opts.with_indifferent_access
    opts[:data] = {} unless opts[:data]
    opts[:data]["content-type"] = opts[:data][:mime_type] unless opts[:data][:mime_type].nil?      
    if opts.class == ActionController::Parameters
      file_entity = Node.new( opts.permit(:data, :associations, :binding) ) 
    else
      file_entity = Node.new( opts.slice(:data, :associations, :binding) ) 
    end
    file_entity.pool = pool
    file_entity.extend FileEntity
    file_entity.file_entity_type = "S3"
    if file_entity.storage_location_id.include?(file_entity.bucket)
      file_entity.storage_location_id = Bindery::Storage::S3.key_from_filepath(file_entity.storage_location_id,bucket:file_entity.bucket) 
    end
    file_entity.model = Model.file_entity
    file_entity.save!
    file_entity.send(:set_metadata)
    return file_entity
  end
  
  def file_entity_type=(name)
    data['file_entity_type'] = name
  end

  def file_entity_type
    data['file_entity_type']
  end
  
  def file_name=(name)
    data['file_name'] = name
  end

  def file_name
    data['file_name']
  end
  
  def file_size=(name)
    data['file_size'] = name
  end

  def file_size
    data['file_size']
  end

  def bucket=(name)
    data['bucket'] = name
  end

  def bucket
    data['bucket'] ||= pool.persistent_id
  end
  
  # Returns an authorized S3 url for the corresponding S3 content
  # Accepts all the same parameters as AWS::S3::S3Object.url_for
  # Default Values for options Hash:
  #   * method: :read
  #   * The url authorization expires afte 1.5 hours.
  #   * response_content_disposition: "inline; filename=#{file_name}"
  def s3_url(method=:read, options={})
    default_options = {response_content_disposition: "inline; filename=#{file_name}", expires: 60 * 60 * 1.5}
    options = default_options.merge(options)
    return pool.default_file_store.get(bucket, storage_location_id).url_for(method, options)
  end
  
  # The id used to find file in file store (ie. S3 object key)
  def storage_location_id
    data["storage_location_id"] ||= self.generate_uuid   # make sure persistent_id is set & use that
  end
  
  def storage_location_id=(new_id)
    data["storage_location_id"] = new_id
  end

  def mime_type
    # we can get this from s3, but keep it cached locally so we know what kind of presentation to use
    data['content-type']
  end

  def mime_type=(mime_type)
    data['content-type'] = mime_type
  end

  # fetch from s3
  def content
    s3_obj.read
  end

  # Store in s3
  def content=(file)
    @content_changed = true
    @content = file
  end

  
  def save
    store_content
    super
  end

  def save!
    store_content
    super
  end
  
  def audio?
    ["audio/mp3", "audio/mpeg"].include? self.mime_type
  end
  
  def video?
    ["video/mpeg", "video/mp4", "video/x-msvideo", "video/avi", "video/quicktime"].include? self.mime_type
  end
  
  def image?
    ["image/png","image/jpeg", 'image/jpg', 'image/bmp', "image/gif"].include? self.mime_type
  end
  
  def pdf?
    ["application/pdf"].include? self.mime_type
  end

  # Set metadata (ie. filename for insertion into Content-Disposition) on object in remote file store
  def set_metadata
    s3_obj.metadata["filename"] = file_name
    s3_obj.metadata["bindery-pid"] = persistent_id
  end
  
  private

  def s3_obj
    @s3_object ||= pool.default_file_store.get(bucket, storage_location_id)
  end

  # Stores content in bucket (usually bucket name is the pool's persistent_id) with id of storage_location_id (usually Node persistent_id)
  # After storing the object, sets metadata like Content-Disposition
  def store_content
    if @content_changed
      @s3_object = pool.default_file_store.put(bucket, storage_location_id, @content)
      set_metadata
    end
    @content_changed=false
  end

end
