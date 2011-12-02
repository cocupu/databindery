class Property
  include Mongoid::Document
  belongs_to :model_instance
  belongs_to :field
  validates_presence_of :field
  validates_presence_of :model_instance
  field :value
end
