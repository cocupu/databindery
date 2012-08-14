class Model < ActiveRecord::Base
  serialize :fields, Array 
  serialize :associations, Array 

  after_initialize :init

  validates :name, :presence=>true
  has_many :nodes

  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true

  def init
    self.fields ||= []
    self.associations ||= []
  end

  def index
    ## only index the most recent version of each node
    max_ids = Node.select('max(id) as max_id').where('model_id = ?', self.id).group(:persistent_id).map(&:max_id)
    Cocupu.index(Node.find(max_ids).map {|m| m.to_solr })
  end

  def keys
    fields.map{|f| f[:code]}
  end

  def self.field_name(label)
    label.downcase.gsub(/\s+/, '_')
  end
end
