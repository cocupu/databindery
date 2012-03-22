class Model
  include Ripple::Document
  #'fields' is already a method in a mongoid document, so it's a poor choice
  many :m_fields, :class_name=>"Field"

  #TODO has_many
  #many :instances, :class_name=>"ModelInstance"
  def instances
    ModelInstance.find_by_index(:model_id, self.key)
  end


  property :name, String, :index=>true


  def index
    fields = m_fields
    Cocupu.index(instances.map {|m| m.to_solr(fields) })
  end
end
