class Model < ActiveRecord::Base
  #'fields' is already a method in a mongoid document, so it's a poor choice
  #many :m_fields, :class_name=>"Field"
  serialize :fields, ActiveRecord::Coders::Hstore

  has_many :instances, :class_name=>'Node'

  def index
    ## only index the most recent version of each node
    max_ids = Node.select('max(id) as max_id').where('model_id = ?', self.id).group(:persistent_id).map(&:max_id)
    Cocupu.index(Node.find(max_ids).map {|m| m.to_solr(fields.keys) })
  end
end
