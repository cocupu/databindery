class Property
  include Ripple::Document
  belongs_to :field #TODO can this be removed and just stored as Field.many :property ?
  validates_presence_of :field
  property :value, String
end
