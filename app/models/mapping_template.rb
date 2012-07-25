class MappingTemplate < ActiveRecord::Base
  serialize :models, Hash 

  after_initialize :init

  def init
    self.models ||= {}
  end

  def attributes=(attrs)
    attrs[:row_start] = attrs.delete(:row_start).to_i if attrs[:row_start]
    super(attrs)
  end

  def models_attributes=(attrs)
    attrs.each_value do |value|
      #TODO constrain to pool
      model = Model.find_or_initialize_by_name(value[:name])
      
      mapping = {} 
      value[:field_mappings_attributes].each_value do |map|
        next unless map[:label].present?
        field_code = map[:label].downcase.gsub(/\s+/, '_')
        model.fields[field_code] = map[:label]
        mapping[map[:source]] = field_code
      end
      model.save!
      models[model.id] ||= {}
      models[model.id][:field_mappings] = mapping  # Alert: this overwrites the old map if it existed
    end
  end

end
