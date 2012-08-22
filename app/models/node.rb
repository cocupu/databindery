class Node < ActiveRecord::Base
  before_create :generate_uuid
  belongs_to :model
  belongs_to :pool
  validates :model, presence: true
  validates :pool, presence: true

  serialize :data, Hash
  serialize :associations, Hash

  after_save :update_index
  after_destroy :remove_from_index
  attr_accessible :data
  attr_accessible :data, :associations, :binding, :model_id, :pool_id, :persistent_id, :parent_id,  :identity_id, :as => :admin

  ## Id is our version, so this ensures that find_by_persistent_id always returns the most recent version
  default_scope order('id desc')

  def to_param
    # Do we need to_key also?
    persistent_id
  end

  def remove_from_index
    Cocupu.solr.delete_by_id self.id
    Cocupu.solr.commit
  end

  def update_index
    Cocupu.index(self.to_solr)
    Cocupu.solr.commit
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

  def to_solr() 
    doc = {'format'=>'Node', 'title'=> title, 'id' => persistent_id, 'version'=>id, 'model' => model.id, 'model_name' => model.name, 'pool' => pool_id}
    return doc if data.nil?
    model.fields.each do |f|
      doc[Node.solr_name(f[:code])] = data[f[:code]]
    end
    doc
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

  def self.solr_name(field_name)
    field_name.downcase.gsub(' ','_') + "_t"
  end

  # Get the latest version of the node with this persistent id
  def self.latest_version(persistent_id) 
    Node.where(:persistent_id=>persistent_id).order('created_at desc').first
  end

end
