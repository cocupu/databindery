class Pool < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true
  has_many :exhibits, :dependent => :destroy
  has_many :nodes, :dependent => :destroy
  has_many :models, :dependent => :destroy
  has_many :mapping_templates, :dependent => :destroy
  has_many :s3_connections, :dependent => :destroy

  validates :short_name, :format=>{:with => /\A[\w-]+\Z/}, :uniqueness => true
  
  def short_name=(name)
    write_attribute :short_name, name.downcase
  end

  def to_param
    short_name
  end

  def all_fields
    self.models.map {|m| m.fields}.flatten.uniq.sort{|x, y| x[:name] <=> y[:name]}
  end

  def default_file_store
    s3_connections.first
  end
end
