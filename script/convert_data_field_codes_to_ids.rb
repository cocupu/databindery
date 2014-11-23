errors = {}
puts "#{Pool.count} pools to process."
Pool.all.each do |pool|
  errors[pool.id] = []
  nodes_head = pool.nodes_head
  puts "Processing #{pool.name} (#{pool.short_name}) -- head contains #{nodes_head.count} nodes of #{pool.nodes.count} total node versions"
  nodes_head.each_with_index do |node, id|
    if (id % 250 == 0)
      print "."
      STDOUT.flush
    end
    begin
      node.convert_data_field_codes_to_id_strings!
      node.log = "DataBindery upgrade: Converting data field codes to id strings."
      node.save
    rescue
      errors[pool.id] << node.id
    end
  end
  puts "Finished #{pool.short_name} with #{errors[pool.id].length} errors."
end
puts "Errors:"
puts errors