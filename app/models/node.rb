class Node < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  before_create :generate_uuid
  belongs_to :model
  belongs_to :pool
  validates :model, presence: true
  validates :pool, presence: true

  serialize :data, Hash
  serialize :associations, Hash

  after_save :update_index
  after_destroy :remove_from_index
  after_find :add_behaviors

  ## Id is our version, so this ensures that find_by_persistent_id always returns the most recent version
  default_scope order('id desc')

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

  def generate_uuid
    self.persistent_id= UUID.new.generate if !persistent_id
  end

  # override activerecord to copy-on-write
  def update
    n = Node.new
    copied_values = self.attributes.select {|k, v| !['created_at', 'updated_at', 'id'].include?(k) }
    copied_values[:parent_id] = id
    n.assign_attributes(copied_values, :as=>:admin)
    n.save
    n
  end

  def attach_file(file_name, file)
    node = Node.new
    node.extend FileEntity
    node.file_name = file_name
    node.pool= pool
    node.model= Model.file_entity
    node.bucket = 'cocupu' # s3 bucket name
    node.content = file.read
    node.content_type = file.content_type
    node.save!
    associations['files'] ||= []
    associations['files'] << node.persistent_id
    update
  end

  def files
    associations['files'] ||= []
  end

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
    model.associations.each do |f|
      instances = find_association(f['code'])
      next unless instances
      find_association(f['code']).each do |instance|
        instance.solr_attributes(f['code'] + '__').each do |k, v|
          doc[k] ||= []
          doc[k] << v
        end
      end
    end
    doc
  end

  # Produce the part of the solr document that is just the model attributes
  def solr_attributes(prefix = "")
    doc = {}
    return doc if data.nil?
    model.fields.each do |f|
      val = data[f['code']]
      if val
        doc[Node.solr_name(f['code'], prefix: prefix)] = val
        doc[Node.solr_name(f['code'], type: 'facet', prefix: prefix)] = val
      end
    end
    doc
  end

  # TODO grab this info out of solr.
  def find_association(type) 
    associations[type] ? associations[type].map { |pid| Node.latest_version(pid) } : nil
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

  def associations_for_json
    output = {}
    model.associations.each do |a|
      assoc_name = a[:name]
      assoc_code = a[:code]
      output[assoc_name] = []
      if associations[assoc_code]
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
    output['files'] = []
    if associations['files']
      associations['files'].each do |id| 
        node = Node.latest_version(id)
        output['files'] << node.association_display if node
      end
    end
    output
  end

  def self.solr_name(field_name, args = {})
    type = args[:type] || "text"
    prefix= args[:prefix] || ''
    suffix = case type
      when "text"
        '_t'
      when "facet"
        '_facet'
      else
        raise "Unknown solr suffix for #{type}"
      end
    prefix + field_name.downcase.gsub(/\s+/,'_') + suffix 
  end

  # Get the latest version of the node with this persistent id
  def self.latest_version(persistent_id) 
    Node.where(:persistent_id=>persistent_id).order('created_at desc').first
  end

  def latest_version
    Node.latest_version(persistent_id)
  end
  
  def as_json(opts = nil)
    h = super
    h['title'] = self.title
    h
  end

end
