class FieldMapping
  include Mongoid::Document
  embedded_in :template_model_mapping

  field :label, type: String
  field :source, type: String
end
