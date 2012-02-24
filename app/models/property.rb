class Property
  include Ripple::Document
  one :model_instance  #TODO remove if possible
  belongs_to :field
  validates_presence_of :field
  validates_presence_of :model_instance
  property :value, String
end
