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


# Destroy all nodes created in the last hour in a given pool
pool = Pool.find(...)
pool.nodes.where("created_at > ?", Time.now -  1*60*60).each {|n| n.destroy}
