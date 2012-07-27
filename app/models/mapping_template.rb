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
      original_mapping = {}
      value[:field_mappings_attributes].each_value do |map|
        field_code = map[:label].downcase.gsub(/\s+/, '_')
        unless field_code.blank? 
          model.fields[field_code] = map[:label]
          mapping[map[:source]] = field_code 
        end
        original_mapping[map[:source]] = map[:label]
      end
      begin
        model.save!
      rescue  ActiveRecord::RecordInvalid => e
        # the model didn't save, so use '' as the key if that's the case
        models[''] ||= {}
        models[''][:field_mappings] = original_mapping  # Alert: this overwrites the old map if it existed
        raise e
      end
      models[model.id] ||= {}
      models[model.id][:field_mappings] = mapping.delete_if { |k, v| v.blank? } # Alert: this overwrites the old map if it existed
    end
  end

end
