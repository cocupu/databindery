class Model < ActiveRecord::Base
  FILE_ENTITY_CODE = 'FILE'
  include ActiveModel::ForbiddenAttributesProtection

  has_many :node

  # NOTE: associations are a subset of fields.  You can create/modify fields via either .fields or .associations methods.
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :associations, -> {where type:"OrderedListAssociation"}, class_name:"OrderedListAssociation", join_table:"fields_models", foreign_key: "model_id", association_foreign_key:"field_id"
  accepts_nested_attributes_for :fields, allow_destroy: true
  accepts_nested_attributes_for :associations, allow_destroy: true

  # Legacy data in :fields and :associations attributes on Model objects
  serialize :associations, Array
  serialize :fields, Array
  belongs_to :pool
  validates :pool, presence: true, :unless=>:code

  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true, :unless=>:code

  validates :label, :inclusion => {:in=> lambda {|foo| foo.keys }, :message=>"must be a field"}, :if=>Proc.new { |a| a.label }
  validates :name, :presence=>true

  after_initialize :init

  #TODO add a fk on node.model_id
  has_many :nodes, :dependent => :destroy do
    def head
      model_pids = map {|n| n.persistent_id}.uniq
      return model_pids.map {|pid| Node.latest_version(pid)}
    end
  end
  # A more efficient way to load complete head state of all nodes using this model.
  # option to pass :pool argument to explicitly constrain to a specific pool
  # @example model.nodes_head(pool:23)
  def nodes_head(args = {})
    if args.has_key?(:pool)
      if args[:pool].instance_of?(Pool)
        pool_id = args[:pool].id
      else
        pool_id = args[:pool]
      end
      sql_query = "SELECT DISTINCT persistent_id FROM nodes WHERE model_id = #{self.id} AND pool_id = #{pool_id}"
    else
      sql_query =  "SELECT DISTINCT persistent_id FROM nodes WHERE model_id = #{self.id}"
    end
    node_pids = ActiveRecord::Base.connection.execute(sql_query).values
    return node_pids.map {|pid| Node.latest_version(pid)}
  end

  def self.for_identity_and_pool(identity, pool)
    # Cancan 1.6.8 was producing incorrect query, for accessible_by:
    #SELECT "models".* FROM "models" INNER JOIN "pools" ON "pools"."id" = "models"."pool_id" WHERE (("models"."pool_id" IS NULL) OR ("pools"."owner_id" = 134))
    # So, lets' write something custom:
    Model.joins("LEFT OUTER JOIN pools ON models.pool_id = pools.id").where("(owner_id = ? AND pool_id = ?) OR pool_id is NULL", identity.id, pool.id)
  end

  def self.for_identity(identity)
    # Cancan 1.6.8 was producing incorrect query, for accessible_by:
    #SELECT "models".* FROM "models" INNER JOIN "pools" ON "pools"."id" = "models"."pool_id" WHERE (("models"."pool_id" IS NULL) OR ("pools"."owner_id" = 134))
    # So, lets' write something custom:
    Model.joins("LEFT OUTER JOIN pools ON models.pool_id = pools.id\n" +
    "LEFT OUTER JOIN access_controls ON access_controls.pool_id = models.pool_id").where("(owner_id = ?) OR models.pool_id is NULL OR access_controls.identity_id = ?", identity.id, identity.id)
  end


  # Return true if this model is the file_entity for this identity
  def file_entity?
    code == FILE_ENTITY_CODE
  end

  def self.file_entity
    Model.where(code: FILE_ENTITY_CODE).first_or_create!(code: FILE_ENTITY_CODE, name: "File Entity", label:'file_name', fields_attributes: [{'code' => 'file_name', 'type' => 'TextField', 'name' => "Filename"}, {'code' => 'content_type', 'type' => 'TextField', 'name' => "Content Type"}] )
  end
  
  # @return [Boolean] current value of allow_file_bindings attribute
  def allows_file_bindings?
    return allow_file_bindings
  end

  def init
    #self.fields ||= []
    #self.associations ||= []
  end

  def index
    ## only index the most recent version of each node
    max_ids = Node.unscoped.select('max(id) as max_id').where('model_id = ?', self.id).group(:persistent_id).map(&:max_id)
    Bindery.index(Node.find(max_ids).map {|m| m.to_solr })
  end

  def keys
    fields.map{|f| f['code']}
  end

  def self.field_name(label)
    if label.nil? || label.empty?
      UUID.new.generate
    else
      label.downcase.gsub(/\s+/, '_').gsub(/\W+/, '')
    end
  end

  # Return the Model's array of fields and associations as they are ordered in the edit view
  def ordered_fields_and_associations
    self.fields.concat(self.associations)
  end
  
end
