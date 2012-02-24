class FieldMapping
  include Ripple::EmbeddedDocument
  #embedded_in :template_model_mapping

  property :label, String
  property :source, String
end
