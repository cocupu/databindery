class Model
  include Mongoid::Document
  #'fields' is already a method in a mongoid document, so it's a poor choice
  has_many :m_fields, :class_name=>"Field"
end
