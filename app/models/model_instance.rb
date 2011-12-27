class ModelInstance
  include Mongoid::Document
  belongs_to :model
  validates_presence_of :model

  # keys are refs to model.m_fields 
  has_many :properties
  
  def cached_fields()
    return @_cached_fields if @_cached_fields
    @_cached_fields = {}
    model.m_fields.each do |f|
      property = properties.where(:field_id=>f.id).first
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
      doc[f.solr_name] = properties.where(:field_id=>f.id).first.value
    end
    doc
  end
end
