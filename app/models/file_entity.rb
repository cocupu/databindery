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
    data['bucket'] 
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
    @s3_object ||= pool.default_file_store.get(data['bucket'], data['file_name'])
  end

  def store_content
    if @content_changed
      pool.default_file_store.put(data['bucket'], data['file_name'], @content)
    end
    @content_changed=false
  end

end
