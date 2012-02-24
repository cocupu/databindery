class MappingTemplate
  include Ripple::Document
  property :row_start, Integer
  many :models, :class_name=>"TemplateModelMapping"

  accepts_nested_attributes_for :models, :reject_if => lambda { |a| a.values.all?(&:blank?) }, :allow_destroy => true

  def attributes=(attrs)
    attrs[:row_start] = attrs[:row_start].to_i if attrs[:row_start]
    super(attrs)
  end

end
