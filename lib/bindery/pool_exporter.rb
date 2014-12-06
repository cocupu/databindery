module Bindery
  class PoolExporter


    # Work In Progress!
    # @example export Nodes with pool_id and data
    #   pool.export(attributes:[:pool_id, :data])
    def export(pool, opts={})
      if  opts[:format] && opts[:format] != :json
        raise ArgumentError, "Export currently only supports json.  You requested #{opts[:format]}"
      end
      filepath_for_export = File.join("tmp",persistent_id,Time.now.nsec,short_name+"_#{DateTime.now.strftime("%FT%H%M")}.json")
      attributes_to_export= opts.fetch(:attributes,[:data])

      File.open(filepath_for_export,"w") do |f|
        pool.node_pids.each do |node_pid|
          node = Node.latest_version(node_pid)
          f << convert_node_data(node).to_json
          f << "\n"
        end
      end
      return filepath_for_export
    end

    def convert_node_data(node)
      field_map = node.model.map_field_codes_to_id_strings.invert
      converted_data = node.data.dup
      field_map.each_pair do |field_id_string,field_code|
        if converted_data.has_key?(field_id_string)
          converted_data[field_code] = converted_data.delete(field_id_string)
        end
      end
      # node.data.each_pair do |k,v|
      #   converted_data[field_map[k]] = v
      # end
      converted_data
    end

  end
end