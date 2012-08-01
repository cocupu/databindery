class Node < ActiveRecord::Base
  before_create :generate_uuid
  belongs_to :model
  belongs_to :pool
  validates :model, presence: true
  validates :pool, presence: true

  serialize :data, Hash


  def generate_uuid
    self.persistent_id= UUID.new.generate if !persistent_id
  end

  # override activerecord to copy-on-write
  def update
    Node.create(self.attributes)
  end

  def to_solr(fields) 
    doc = {'id' => persistent_id, 'version_s'=>id, 'model' => model.name, 'pool_s' => pool_id}
    return doc if data.nil?
    model.fields.each_key do |f|
      doc[Node.solr_name(f)] = data[f]
    end
    doc
  end

  def self.solr_name(field_name)
    field_name.downcase.gsub(' ','_') + "_s"
  end
end
