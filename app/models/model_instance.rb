class ModelInstance
  include Ripple::Document
  validates_presence_of :model

  belongs_to :model

  # keys are refs to model.m_fields 
  many :properties

  alias_method :id, :key
  
  def cached_fields()
    return @_cached_fields if @_cached_fields
    @_cached_fields = {}
    model.m_fields.each do |f|
      property = properties.select{|p| p.field_id == f.key}.first
      @_cached_fields[f.label] = property.value if property
    end
    @_cached_fields
  end

  def get(label)
    cached_fields[label]
  end

  def to_solr(fields) 
    doc = {'id' => id, 'model' => model.name}

    model.m_fields.each do |f|
      doc[f.solr_name] = properties.select{|p| p.field_id==f.key}.first.value
    end
    doc
  end
end
