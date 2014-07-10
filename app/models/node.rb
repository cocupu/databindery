class Node < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Bindery::Identifiable
  
  before_create :generate_uuid
  belongs_to :model
  belongs_to :pool
  belongs_to :spawned_from_datum, class_name: "SpreadsheetRow"
  belongs_to :modified_by, class_name: "Identity"
  validates :model, presence: true
  validates :pool, presence: true

  serialize :data, Hash
  serialize :associations, Hash

  before_save :update_file_ids
  after_save :update_index
  after_destroy :remove_from_index
  after_find :add_behaviors

  ## Id is our version, so this ensures that find_by_persistent_id always returns the most recent version
  default_scope { order('id desc') }

  # If the type is "File Entity"
  def add_behaviors
    if model && model.file_entity?
      extend FileEntity
    end
  end

  def to_param
    # Do we need to_key also?
    persistent_id
  end

  def remove_from_index
    Bindery.solr.delete_by_id self.persistent_id
    Bindery.solr.commit
  end

  def update_index
    Bindery.index(self.to_solr)
    Bindery.solr.commit
  end
  
  # Overrides default assign_attributes behavior.
  # Resets modified_by every time the attributes change via this method 
  #  -- if you don't provide modified_by or modified_by_id, it will be set to nil
  def assign_attributes(new_attributes)
    return unless new_attributes
    unless (new_attributes.has_key?(:modified_by) && !new_attributes[:modified_by].nil?) || (new_attributes.has_key?(:modified_by_id) && !new_attributes[:modified_by_id].nil?)
      self.modified_by = nil
    end
    super
  end

  # Overrides alias that points to ActiveRecord::AttributeAssignment.assign_attributes.  Point to local method instead.
  alias attributes= assign_attributes
  
  # copy-on-write
  # Mints a new node version with updated attributes, saves that new version and returns it
  def update
    update_file_ids
    n = Node.new
    copied_values = self.attributes.select {|k, v| !['created_at', 'updated_at', 'id'].include?(k) }
    copied_values[:parent_id] = id
    n.assign_attributes(copied_values)
    n.save
    n
  end

  # override activerecord updates to use custom copy-on-write
  def update_record
    update
  end

  # reroute  activerecord updates to use custom copy-on-write
  #def create_or_update
  #  raise ReadOnlyRecord if readonly?
  #  #result = new_record? ? create_record : update_record
  #  if new_record?
  #    result = create_record
  #  else
  #    result = update
  #  end
  #  result != false
  #end

  # Stores file in an S3 bucket named after its Pool's persistent_id
  def attach_file(file_name, file)
    node = Node.new
    node.extend FileEntity
    node.file_name = file_name
    node.pool= pool
    node.model= Model.file_entity
    raise StandardError, "You can't add files to a Pool that hasn't been persisted.  Save the pool first." unless pool.persisted?
    node.bucket = pool.persistent_id # s3 bucket name
    node.content = file.read
    if file.respond_to?(:mime_type)
      node.mime_type = file.mime_type
    end
    node.save!
    files << node
    # associations['files'] ||= []
    # associations['files'] << node.persistent_id
    update
  end

  # This list is persisted as an array of persistent_ids in associations["files"]
  # It's persisted as an array of ids rather than an association in database because order is relevant and multiple nodes might reference the same file.
  # DO NOT manipulate associations["files"] directly.  Those changes will not be persisted.
  def files
    if associations['files'].nil? 
      @files ||= []
    else
      @files ||= associations['files'].map{|pid| Node.find_by_persistent_id(pid).extend(FileEntity)}
    end
  end
  
  def files=(new_files)
    if new_files.kind_of? Array
      @files = new_files
    elsif new_files.kind_of? Node
      @files = [new_files]
    else
      raise ArgumentError, "You can only pass an Array or a single Node into Node.files=.  You passed in a #{new_files.class} that looks like this:  #{new_files.inspect}"
    end
    update_file_ids
    return @files
  end
  
  # Tracks a list of associated files by id. 
  # Note: Use .files accessor to set & get file associations.
  # DO NOT manipulate this array or the associations["files"] array directly.  Those changes will not be persisted. 
  def file_ids
    ids = update_file_ids
    # this will be nil if no file associations have been set, so return an empty Array.
    if ids.nil?
      return []
    else
      return ids
    end
  end
  
  # Updates associations['files'] based on the current contents of @files attribute
  # If @files is empty, the associations will be left untouched.
  def update_file_ids
    # Don't set "files" key in associations hash unless there are files to associate.
    associations['files'] = files.map{|file| file.persistent_id} unless files.empty?
  end
  private :file_ids, :update_file_ids

  # Create a solr document for all the attributes as well as all the associations
  def to_solr() 
    doc = {'format'=>'Node', 'title'=> title, 'id' => persistent_id, 'version'=>id, 'model' => model.id, 'model_name' => model.name, 'pool' => pool_id}
    doc.merge!(solr_attributes)
    doc.merge!(solr_associations)
    doc
  end

  # Solrize all the associated models (denormalize) onto this record
  # For example, if this object is a book, you will be able to search by the associated author's name
  def solr_associations
    doc = {}
    update_file_ids
    model.associations.each do |f|
      instances = find_association(f['code'])
      next unless instances
      doc["bindery__associations_facet"] ||= []
      find_association(f['code']).each do |instance|
        doc["bindery__associations_facet"] << instance.persistent_id
        facet_name_for_association = Node.solr_name(f['code'], type: 'facet', multiple:true)
        doc[facet_name_for_association] ||= []
        doc[facet_name_for_association] << instance.title
        field_name_for_association = Node.solr_name(f['code'], multiple:true)
        doc[field_name_for_association] ||= []
        doc[field_name_for_association] << instance.title
        instance.solr_attributes(f['code'] + '__', multiple:true).each do |k, v|
          doc[k] ||= []
          doc[k] << v
        end
      end
    end
    doc
  end

  # Produce the part of the solr document that is just the model attributes
  def solr_attributes(prefix = "", opts={})
    doc = {}
    return doc if data.nil?
    model.fields.each do |f|
      val = data[f['code']]
      if opts[:multiple]
        f['multiple'] = true
      end
      if val
        doc[Node.solr_name(f['code'], prefix: prefix, multiple:f['multiple'])] = val
        doc[Node.solr_name(f['code'], type: 'facet', prefix: prefix)] = val
      end
    end
    doc
  end

  # TODO grab this info out of solr.
  def find_association(type) 
    associations[type] && (associations[type] != "") ? associations[type].map { |pid| Node.latest_version(pid) } : nil
  end

  def reify_association(type)
    find_association(type)
  end
  
  # Relies on a solr search to returns all Nodes that have associations pointing at this node
  def incoming(opts={})
    # Constrain results to this pool
    fq = "format:Node"
    # fq += " AND pool:#{pool.id}"
    http_response = Bindery.solr.select(params: {q:persistent_id, qf:"bindery__associations_facet", qt:'search', fq:fq})
    results = http_response["response"]["docs"].map{|d| Node.find_by_persistent_id(d['id'])}
  end

  def title
    data[model.label].present? ? data[model.label] : persistent_id
  end


  def association_display
    serializable_hash(:only=>[:id, :persistent_id], :methods=>[:title])
  end

  def serializable_hash(args)
    hash = super
    hash['id'] = hash['persistent_id']
    hash
  end

  def as_json(opts=nil)
    h = super
    h["pool"] = pool.short_name
    h["identity"] = pool.owner.short_name
    h["title"] = title
    h["node_version_id"] = id
    #h.merge!(h.delete("associations"))
    #h.merge!(h.delete("data"))
    h
  end
  
  def associations_for_json
    output = {}
    update_file_ids
    model.associations.each do |a|
      assoc_name = a[:name]
      assoc_code = a[:code]
      output[assoc_name] = []
      if associations[assoc_code] && associations[assoc_code].kind_of?(Array)
        associations[assoc_code].each do |id|
          node = Node.latest_version(id)
          output[assoc_name] <<  node.association_display if node
        end
      end
    end
    output['undefined'] = []
    if associations['undefined']
      associations['undefined'].each do |id| 
        node = Node.latest_version(id)
        output['undefined'] << node.association_display if node
      end
    end
    if files
      output['files'] = [] 
      files.each do |file_entity| 
        output['files'] << file_entity.association_display 
      end
    end
    output
  end

  def self.solr_name(field_name, args = {})
    if ["model_name", "model", "*"].include?(field_name)
      return field_name
    end
    type = args[:type] || "text"
    prefix= args[:prefix] || ''
    suffix = case type
      when "text"
        args[:multiple] ? '_t' : '_s'
      when "facet"
        '_facet'
      else
        raise "Unknown solr suffix for #{type}"
      end
    prefix + field_name.downcase.gsub(/\s+/,'_') + suffix 
  end

  # Get the versions of the node with this persistent id in descending order of creation (newest first)
  def self.versions(persistent_id)
    Node.where(:persistent_id=>persistent_id).order('created_at desc')
  end

  def versions
    Node.versions(persistent_id)
  end

  # Get the latest version of the node with this persistent id
  def self.latest_version(persistent_id) 
    Node.versions(persistent_id).first
  end

  def latest_version
    Node.latest_version(persistent_id)
  end

  # Returns the node (version) where the latest file binding was set
  def self.version_with_latest_file_binding(persistent_id)
    self.versions(persistent_id).where(binding: self.latest_version(persistent_id).binding).last
  end

  # Returns the node (version) where the current node's file binding was set
  def version_with_current_file_binding
    self.versions.where(binding: self.binding).last
  end
  
  # Retrieves node by node_id.
  # Inspects the value to decide whether to use .find(node_id) or .find_by_persistent_id(node_id)
  def self.find_by_identifier(node_id)
    # really nasty way of testing whether node_id is an integer
    node_id_is_integer =  node_id.kind_of?(Integer) || node_id.to_i.to_s.length == node_id.length
    if node_id_is_integer
      node = self.find(node_id)
    else
      node = self.find_by_persistent_id(node_id)
    end
    return node
  end

end
