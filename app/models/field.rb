class Field
  include Ripple::Document
  #one :model#, :inverse_of=>:m_fields
  property :label, String

  alias_method :id, :key

  def solr_name
    label.downcase.gsub(' ','_') + "_s"
  end
end
