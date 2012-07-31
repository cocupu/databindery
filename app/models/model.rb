class Model < ActiveRecord::Base
  serialize :fields, ActiveRecord::Coders::Hstore

  after_initialize :init

  validates :name, :presence=>true
  has_many :instances, :class_name=>'Node'

  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true

  def init
    self.fields ||= {}
  end

  def index
    ## only index the most recent version of each node
    max_ids = Node.select('max(id) as max_id').where('model_id = ?', self.id).group(:persistent_id).map(&:max_id)
    Cocupu.index(Node.find(max_ids).map {|m| m.to_solr(fields.keys) })
  end
end
