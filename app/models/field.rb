class Field
  include Mongoid::Document
  belongs_to :model, :inverse_of=>:m_fields
  field :label, type: String

  def solr_name
    label.downcase.gsub(' ','_') + "_s"
  end
end
