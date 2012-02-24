class TemplateModelMapping
  include Ripple::EmbeddedDocument
  # embedded_in :mapping_template
  many :field_mappings

  accepts_nested_attributes_for :field_mappings, :reject_if => lambda { |a|  a.values.all?(&:blank?) }, :allow_destroy => true

  validates_presence_of :name

  property :name, String, :index=>true
  property :filter_source, String
  property :filter_predicate, String
  property :filter_constant, String
  property :filter, Boolean

  def referenced_model()
    results = Model.find_by_index(:name, name)  ### TODO Looking up by name probably isn't the best way. 
    model = results.first
    raise "unable to find model named #{name}" unless model
    model
  end

end

