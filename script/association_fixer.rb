identity_short_name = "birgitscott"
pool_short_name = "ktgrtp"

identity =  Identity.find_by_short_name(identity_short_name)
pool = Pool.where(owner_id:identity.id, short_name:"ktgrtp").first

head =  pool.nodes.head

problems = {}
head.each do |n|
  n.associations.each_pair do |k,v|
    unless v.kind_of?(Array) || v.nil?
      problems[n.persistent_id] ||= {}
      problems[n.persistent_id][k] = v
      if v == ""
        n.associations[k] = []
        n.save
        problems[n.persistent_id][k] = "FIXED"
      end
    end
  end
end
puts problems.inspect
