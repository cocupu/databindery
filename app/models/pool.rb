class Pool < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Bindery::Identifiable
  
  before_create :generate_uuid
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true
  has_many :exhibits, :dependent => :destroy
  belongs_to :chosen_default_perspective, class_name: "Exhibit"
  has_many :nodes, :dependent => :destroy
  has_many :models, :dependent => :destroy
  has_many :mapping_templates, :dependent => :destroy
  has_many :s3_connections, :dependent => :destroy
  has_many :access_controls, :dependent => :destroy

  validates :short_name, :format=>{:with => /\A[\w-]+\Z/}, :uniqueness => true
  
  attr :generated_default_perspective

  def self.for_identity(identity)
    # Cancan 1.6.8 was producing incorrect query, for accessible_by so,
    # lets' write something custom:
    # Must call unique or the owner will get multiple rows
    Pool.joins("LEFT OUTER JOIN access_controls ON access_controls.pool_id = pools.id").where("(owner_id = ?) OR access_controls.identity_id = ? ", identity.id, identity.id).uniq
  end
  
  def perspectives
    exhibits.unshift(generated_default_perspective)
  end
  
  def default_perspective
    if chosen_default_perspective.nil?
      generated_default_perspective
    else
      chosen_default_perspective  
    end
  end
  
  def generated_default_perspective
    all_field_codes = all_fields.map {|f| f["code"]}.uniq
    @generated_default_perspective ||= Exhibit.new(pool_id:self.id, index_fields: all_field_codes, facets: all_field_codes, title: "All Content, All fields")
  end

  
  def short_name=(name)
    write_attribute :short_name, name.downcase
  end
  
  def file_store
    raise StandardError, "You can't call file_store on a Pool that hasn't been persisted.  Save the pool first." unless persisted?
    Bindery::Storage::S3::FileStore.new(bucket_name: persistent_id)
  end
  
  #
  # Serialization
  #
  def to_param
    short_name
  end

  def all_fields
    self.models.map {|m| m.fields}.flatten.uniq.sort{|x, y| x[:name] <=> y[:name]}
  end

  def default_file_store
    s3_connections.first
  end

  # Serialize the pool and it's access_controls to a basic datastruture.
  def as_json(opts = nil)
    h = super
    h['access_controls'] = access_controls.map {|ac| {'identity' => ac.identity.short_name, 'access' => ac.access  }}
    h
  end
end
