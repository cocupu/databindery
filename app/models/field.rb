class Field
  include Mongoid::Document
  embedded_in :model, :inverse_of=>:m_fields
  field :label, type: String
end
