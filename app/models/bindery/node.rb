module Bindery::Node
  extend ActiveSupport::Concern

  included do
    include Bindery::Identifiable
    include Bindery::Node::HasFiles
    include Bindery::Node::Finders
    include Bindery::Node::Indexing
    include Bindery::Node::Versioning
    include Bindery::Node::Forking
  end

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
    n = Node.copy(self)
    #update_file_ids
    #n = Node.new
    #copied_values = self.attributes.select {|k, v| !['created_at', 'updated_at', 'id'].include?(k) }
    #copied_values[:parent_id] = id
    #n.assign_attributes(copied_values)
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

end