class JobLogItem
  include Ripple::Document
  #include Ripple::Timestamps
  timestamps!

  property :status, String
  property :name, String
  property :message, String
  #one :parent, :class_name=>"JobLogItem"
  #many :children, :class_name=>"JobLogItem"

  property :parent_id, String, :index=>true
  
  after_update :alert_parent_of_status_change
  alias_method :id, :key


  def parent= p
    self.parent_id = p.key
  end

  def children= children
    children.each do |c|
      c.update_attribute(:parent_id, self.key)
    end
  end

  def parent
    self.class.find(parent_id)
  end

  def find_children_with_status(values)
    tmp_var = 'status'
    status_val = "JSON.parse(v['values'][0]['data']).status"
    status_condition = values.map {|v|"#{tmp_var} == \"#{v}\""}.join(" || ") 
    js = "function(v){ #{tmp_var} = #{status_val}; return #{status_condition} ? [v.key] : [];}"
puts "JS: #{js}"
    bucket = self.class.bucket.name
puts "SELF: #{self.class.name}"
    index = self.class.indexes[:parent_id].index_key
    puts "BUCK #{bucket} #{index}"
    Riak::MapReduce.new(Ripple.client).index(bucket, index, self.id).map(js, :keep => true).run
  end
  

  ## if status is changed, alert the parent
  def alert_parent_of_status_change
    needs_alert = self.previous_changes["status"].present? && parent
    parent.member_finished if needs_alert
  end
  

end
