class Exhibit
  include Ripple::Document
  property :title, String
  many :facets # type: Array

  alias_method :id, :key

  class Facet
    include Ripple::EmbeddedDocument
    property :value, String
  end
end
