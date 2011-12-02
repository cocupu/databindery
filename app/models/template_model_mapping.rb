class TemplateModelMapping
  include Mongoid::Document
  embedded_in :mapping_template
  embeds_many :field_mappings

  field :name, type: String

  def referenced_model()
    model = Model.first(:conditions=>{:name=>name})  ### TODO Looking up by name probably isn't the best way. Index at the least.
    raise "unable to find model named #{name}" unless model
    model
  end
end

