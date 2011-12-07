class TemplateModelMapping
  include Mongoid::Document
  embedded_in :mapping_template
  embeds_many :field_mappings

  accepts_nested_attributes_for :field_mappings, :reject_if => lambda { |a|  a.values.all?(&:blank?) }, :allow_destroy => true

  validates_presence_of :name

  field :name, type: String

  def referenced_model()
    model = Model.first(:conditions=>{:name=>name})  ### TODO Looking up by name probably isn't the best way. Index at the least.
    raise "unable to find model named #{name}" unless model
    model
  end
end

