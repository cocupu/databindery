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
    opts[:data]["content-type"] = opts[:data][:content_type] unless opts[:data][:content_type].nil?      
    if opts.class == ActionController::Parameters
      file_entity = Node.new( opts.permit(:data, :associations, :binding) ) 
    else
      file_entity = Node.new( opts.slice(:data, :associations, :binding) ) 
    end
    file_entity.pool = pool
    file_entity.extend FileEntity
    file_entity.file_entity_type = "S3"
    file_entity.model = Model.file_entity
    file_entity.save!
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
  
  # The id used to find file in file store (ie. S3 object key)
  def storage_location_id
    data["storage_location_id"] ||= self.generate_uuid   # make sure persistent_id is set & use that
  end
  
  def storage_location_id=(new_id)
    data["storage_location_id"] = new_id
  end

  def content_type
    # we can get this from s3, but keep it cached locally so we know what kind of presentation to use
    data['content-type']
  end

  def content_type=(content_type)
    data['content-type'] = content_type
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
  
  # Set metadata (ie. filename for insertion into Content-Disposition) on object in remote file store
  def set_metadata
    @s3_object.metadata["filename"] = file_name
  end

end
