module FileEntity
  def file_name=(name)
    data['file_name'] = name
  end

  def file_name
    data['file_name']
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
