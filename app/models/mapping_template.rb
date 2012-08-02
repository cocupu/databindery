class MappingTemplate < ActiveRecord::Base
  serialize :model_mappings, Array  # one row per model

  after_initialize :init
  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true

  def init
    self.model_mappings ||= []
  end

  def attributes=(attrs)
    attrs[:row_start] = attrs.delete(:row_start).to_i if attrs[:row_start]
    super(attrs)
  end

  def model_mappings_attributes=(attrs)
    attrs.each_value do |value|
      model = Model.find_or_initialize_by_name_and_identity_id(value[:name], owner.id)
      mapping = {} 
      original_mapping = {}
      model_mapping = {:field_mappings => value[:field_mappings_attributes].values, :name=>value[:name], :label=>value[:label]}
      model_mapping[:field_mappings].each do |map|
        field_code = map[:label].downcase.gsub(/\s+/, '_')
        unless field_code.blank? 
          model.fields[field_code] = map[:label]
          model.label= field_code if value[:label] == map[:source]
          map[:field] = field_code
        end
      end
      begin
        model.save!
      rescue  ActiveRecord::RecordInvalid => e
        model_mappings << model_mapping
        raise e
      end
      model_mapping[:model_id] = model.id
      model_mappings << model_mapping
    end
  end

end
