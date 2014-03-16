module Bindery
  class Curator
    # Include Blacklight Solr Search functionality for find_or_create_node
    include Blacklight::Configurable
    include Blacklight::SolrHelper
    include Singleton

    # Spawn new :destination_model nodes using the :source_field_name field from :source_model nodes,
    # setting the extracted value as the :destination_field_name field on the resulting spawned nodes.
    #
    # @param identity_id
    # @param pool_id
    # @param source_model_id Model whose field(s) you're spawning new Nodes from
    # @param source_field_name field name of field to spawn
    # @param association_code Code for the association to use to point from source nodes to spawned nodes
    # @param destination_model_id model to spawn new nodes of
    # @param destination_field_name field name to set on spawned nodes
    def spawn_from_field(identity, pool, source_model, source_field_name, association_code, destination_model, destination_field_name, opts={})
      identity = Identity.find_by_short_name(identity) if identity.instance_of?(String)
      pool = Pool.find_by_short_name(pool) unless pool.instance_of?(Pool)
      source_model = Model.find(source_model) unless source_model.instance_of?(Model)
      unless destination_model.instance_of?(Model)
        begin
          destination_model = Model.find(destination_model)
        rescue ActiveRecord::RecordNotFound
          model_name =  association_code.capitalize
          destination_model = Model.new(pool:pool, label:destination_field_name, name:model_name, owner:pool.owner, fields:[{"code"=>destination_field_name, "name"=>destination_field_name.gsub("_", " ").capitalize}.with_indifferent_access])
          destination_model.save
        end
      end
      ensure_fields_exist_on_model(destination_model, [destination_field_name] + opts.fetch(:also_move,[]) + opts.fetch(:also_copy,[]), source_model: source_model)
      source_model_association = source_model.associations.select {|a| a[:code] == association_code}.first
      if source_model_association.nil?
        association_name = association_code.pluralize.capitalize
        source_model.associations << {"type"=>"Has Many", "references"=>destination_model.id, "code"=>association_code, "name"=>association_name,"label"=>association_name, }.with_indifferent_access
        source_model.save
      elsif source_model_association[:references] != destination_model.id
        raise StandardError, "Source model already has an association called #{association_code}, but it references model #{source_model_association[:references]} when you are trying to use that association to point at model #{destination_model.id}."
      end
      source_nodes = source_model.nodes_head(pool: pool)
      source_field_values = source_nodes.map {|sn| sn.data[source_field_name]}.uniq
      source_field_values.reject! do |v|
        v.nil? || v.empty?
      end
      # puts "Spawning from #{source_field_values.count} field values."
      source_field_values.each do |value_to_spawn|
        # puts '###'+ value_to_spawn
        destination_node_data = {destination_field_name=>value_to_spawn}
        destination_node = find_or_create_node(pool:pool, model:destination_model, data:destination_node_data)
        # puts "...Selecting nodes to process"
        source_nodes_to_process = source_nodes.select {|sn| sn.data[source_field_name] == value_to_spawn}
        # puts "...Found #{source_nodes_to_process.count} nodes to process"
        source_nodes_to_process.each do |sn|
          sn.associations[association_code] = [destination_node.persistent_id]
          if opts[:delete_source_value] == true
            sn.data.delete(source_field_name)
          end
          unless opts[:also_move].nil?
            opts[:also_move].each do |fn|
              if fn.instance_of?(String)
                move_field(fn, sn, destination_node)
              elsif fn.instance_of?(Hash)
                move_field(fn.keys.first, sn, destination_node, rename_to: fn.values.first)
              end
            end
          end
          unless opts[:also_copy].nil?
            opts[:also_copy].each do |fn|
              if fn.instance_of?(String)
                copy_field(fn, sn, destination_node)
              elsif fn.instance_of?(Hash)
                copy_field(fn.keys.first, sn, destination_node, rename_to: fn.values.first)
              end
            end
          end
          sn.save
          # puts "...Processed #{sn.title}"
        end
        # puts "...done with source nodes. saving destination node."
        destination_node.save
      end
      if opts[:delete_source_value] == true
        to_remove = [source_field_name] + opts.fetch(:also_move,[])
        to_remove.each do |field_info|
          if field_info.instance_of?(Hash)
            field_code = field_info.keys.first
          else
            field_code = field_info
          end
          source_model.fields.delete_if {|f| f[:code] == field_code}
        end
        source_model.save
      end
      return source_field_values
    end

    # Move a field and its values from source_node to destination_node
    # This performs copy_field and then deletes the field from the source node.
    def move_field(field_name, source_node, destination_node, opts={})
      copy_field(field_name, source_node, destination_node, opts)
      source_node.data.delete(field_name)
    end

    # Copy a field and its values from source_node to destination_node
    # If the destination node already has values in this field stored as an Array, it appends the ones being copied.
    # If you want to use a new field code in the destination node, pass the new code as the value of :rename_to in the opts Hash
    # This does not delete the field from the source node.  To do that, use move_field.
    def copy_field(field_name, source_node, destination_node, opts={})
      if opts[:rename_to].nil? || opts[:rename_to].empty?
        dest_field_name = field_name
      else
        dest_field_name = opts[:rename_to]
      end
      if destination_node.data[dest_field_name].instance_of?(Array)
        destination_node.data[dest_field_name] << source_node.data[field_name]
      else
        destination_node.data[dest_field_name] = source_node.data[field_name]
      end
    end

    # Uses advanced search request handler to find Nodes matching the request.
    # Currently only searches against attribute values.  Does not search against associations (though associations in the create request will be applied to the Node if created.)
    def find_or_create_node(node_attributes)
      node_attributes = node_attributes.with_indifferent_access
      pool = node_attributes[:pool]
      model = node_attributes[:model]
      node = Node.new(node_attributes)

      if  model.nodes.empty?
        node.save
      else
        # Find...
        # Constrain results to this pool
        fq = "pool:#{pool.id}"
        fq += " AND model:#{model.id}" if model
        fq += " AND format:Node"

        query_parts = []
        node.solr_attributes.each_pair do |key, value|
          query_parts << "#{key}:\"#{value}\""
        end
        query = query_parts.join(" && ")
        # puts query

        ## TODO do we need to add query_fields for File entities?
        query_fields = pool.models.map {|model| model.keys.map{ |key| Node.solr_name(key) } }.flatten.uniq
        (solr_response, facet_fields) = get_search_results( {:q=>query}, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'advanced', :fq=>fq, :rows=>10, 'facet.field' => ['name_s', 'model']})

        #puts "solr_response: #{solr_response.docs}"

        # If any docs were found, load the first result as a node and return that.
        # Otherwise, create a new one based on the params provided.
        first_result = solr_response.docs.first
        if first_result.nil?
          node.save
          #flash[:notice] = "Created a new #{@node.model.name} based on your request."
        else
          node =  Node.find_by_persistent_id(first_result['id'])
          #flash[:notice] = "Found a #{@node.model.name} matching your query."
        end
      end

      return node
    end

    private
    def blacklight_solr
      @solr ||=  RSolr.connect(Blacklight.solr_config)
    end

    def ensure_fields_exist_on_model(destination_model, fields_array, opts)
      if opts.has_key?(:source_model)
        source_model_fields = opts[:source_model].fields
      else
        source_model_fields = {}
      end
      fields_array.each do |field_info|
        if field_info.instance_of?(String)
          field_code = field_info
          field_config = source_model_fields.select {|f| f[:code] == field_info}.first
        elsif field_info.instance_of?(Hash)
          field_code = field_info.values.first
          field_config = source_model_fields.select {|f| f[:code] == field_info.keys.first}.first
        end
        if destination_model.fields.select {|f| f[:code] == field_code}.empty?
          field_config ||= {}.with_indifferent_access
          field_config[:code] = field_code
          field_config[:name] = field_code.gsub("_", " ").capitalize if field_config[:name].nil?
          destination_model.fields << field_config
        end
      end
      destination_model.save
    end
  end
end