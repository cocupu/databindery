class MappingTemplate
  include Mongoid::Document
  field :row_start
  field :models

  def attributes=(attrs)
    attrs[:row_start] = attrs[:row_start].to_i if attrs[:row_start]
    attrs[:models] = MappingTemplate.arrayify_models_parameters(attrs[:models])
    super(attrs)
  end

  private

  def self.arrayify_models_parameters(model_params)
    models = []
    cast_hash_to_array(model_params).each do |field_map|
      mapping = []
      cast_hash_to_array(field_map[:mapping]).each do |item|
        mapping << item if item[:label].present?
      end
      models << {:name=>field_map[:name], :mapping=>mapping}
    end
    models
  end
  
  def self.cast_hash_to_array(hash)
    array = []
    hash.each {|k, v| array[k.to_i] = v}
    array
  end
end
