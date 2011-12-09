class Model
  include Mongoid::Document
  #'fields' is already a method in a mongoid document, so it's a poor choice
  has_many :m_fields, :class_name=>"Field"
  has_many :instances, :class_name=>"ModelInstance"

  def index
    fields = m_fields
    Cocupu.index(instances.map {|m| m.to_solr(fields) })
  end
end
