class Model < ActiveRecord::Base

  class Association
    INBOUND = ['Has Many', 'Has One']
    OUTBOUND = ['Ordered List', 'Unordered List']
    TYPES = INBOUND + OUTBOUND
    instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }
    def initialize(data)
      @data = data
    end

    def data
      @data
    end

    def label
      @label ||= "#{type} #{name.capitalize}"
    end


    def model
      @model ||= Model.find(@data[:references])
    end



    private
    def method_missing(method, *args)
      if @data.has_key?(method)
        @data[method]
      elsif @data.respond_to?(method)
        if block_given?
          @data.send(method, *args)  { |*block_args| yield(*block_args) }
        else
          @data.send(method, *args)
        end
      else
        message = "undefined method `#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
        raise NoMethodError, message
      end
    end
  end

  class AssociationSet
    instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }
    
    def initialize(data)
      @target = data.map { |d| Association.new(d) }
    end

    def target
      @target
    end

    private
    def method_missing(method, *args)
      unless @target.respond_to?(method)
        message = "undefined method `#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
        raise NoMethodError, message
      end

      if block_given?
        @target.send(method, *args)  { |*block_args| yield(*block_args) }
      else
        @target.send(method, *args)
      end
    end
  end


  FILE_ENTITY_CODE = 'FILE'
  include ActiveModel::ForbiddenAttributesProtection
  serialize :fields, Array 
  serialize :associations, Array 

  after_initialize :init

  validates :name, :presence=>true
  #TODO add a fk on node.model_id
  has_many :nodes, :dependent => :destroy

  belongs_to :pool
  validates :pool, presence: true, :unless=>:code

  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true, :unless=>:code

  validates :label, :inclusion => {:in=> lambda {|foo| foo.keys }, :message=>"must be a field"}, :if=>Proc.new { |a| a.label }

  validate :association_cannot_be_named_undefined

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
    Model.where(code: FILE_ENTITY_CODE).first_or_create!(code: FILE_ENTITY_CODE, name: "File Entity", label:'file_name', fields: [{'code' => 'file_name', 'type' => 'textfield' }.with_indifferent_access] )
  end

  def association_cannot_be_named_undefined
    if associations.any?{|a| a[:name] == 'undefined'}
      errors.add(:associations, "name can't be 'undefined'")
    end
  end

  def init
    self.fields ||= []
    self.associations ||= []
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
    label.downcase.gsub(/\s+/, '_')
  end

  def inbound_associations
    @inbound ||= AssociationSet.new(associations.select {|assoc| Association::INBOUND.include?(assoc[:type]) })
  end

  def outbound_associations
    @outbound ||= AssociationSet.new(associations.select {|assoc| Association::OUTBOUND.include?(assoc[:type]) })
  end


  def associations=(attributes)
    write_attribute :associations, []
    attributes.each do |attr|
      add_association(attr)
    end
  end

  def add_association(attributes)
    attributes[:label] = Model.find(attributes[:references]).name.capitalize
    ## TODO association code should be unique
    attributes[:code] = Model.field_name(attributes[:name])
    self.associations << attributes
  end
  
end
