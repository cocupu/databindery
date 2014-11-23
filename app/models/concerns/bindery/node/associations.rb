module Bindery::Node::Associations
  extend ActiveSupport::Concern

  def associations_for_json
    output = {}
    update_file_ids
    model.associations.each do |a|
      output[a.name] = []
      if associations[a.id.to_s] && associations[a.id.to_s].kind_of?(Array)
        associations[a.id.to_s].each do |id|
          node = Node.latest_version(id)
          output[a.name] <<  node.association_display if node
        end
      end
    end
    output['undefined'] = []
    if associations['undefined']
      associations['undefined'].each do |id|
        node = Node.latest_version(id)
        output['undefined'] << node.association_display if node
      end
    end
    if files
      output['files'] = []
      files.each do |file_entity|
        output['files'] << file_entity.association_display
      end
    end
    output
  end

  def association_display
    serializable_hash(:only=>[:id, :persistent_id], :methods=>[:title])
  end

end
