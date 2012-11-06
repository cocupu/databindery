module FileEntity
  def file_name=(name)
    data[:file_name] = name
  end

  def file_name
    data[:file_name]
  end

  def bucket=(name)
    data[:bucket] = name
  end

  def bucket
    data[:bucket] 
  end


  # fetch from s3
  def content
    pool.default_file_store.get(data[:bucket], data[:file_name])
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

  def store_content
    pool.default_file_store.put(data[:bucket], data[:file_name], @content)
    @content_changed=false
  end

end
