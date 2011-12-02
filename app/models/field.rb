class Field
  include Mongoid::Document
  belongs_to :model, :inverse_of=>:m_fields
  field :label, type: String
end
