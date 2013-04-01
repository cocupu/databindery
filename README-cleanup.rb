# Cleaning up bad associations that spawn_from_field created, where the association value is not an Array
pool.nodes.head.each do |node|
  changed = false
  node.associations.each_pair do |code, values|
    unless values.kind_of? Array
      node.associations.delete(code)
      changed = true
    end
  end
  if changed
    puts "Updating #{node.persistent_id}: #{node.associations.inspect}"
    node.save
  end
end