class ConcurrentJob < JobLogItem

  self.bucket_name = JobLogItem.bucket_name

  #after_initialize :init_fields
  def initialize(*args)
    super(*args)
    init_fields
  end

  alias_method :id, :key

  def init_fields
    return unless new_record?
    self.status = "READY"
    self.name = self.class.to_s
  end
  

  def enqueue_collection(job_class, per_job_data, all_job_data)
    self.update_attribute(:status, "PROCESSING")
    per_job_data.each do |data|
puts "DATA IS #{data}"
      log = JobLogItem.create(:status=>"READY", :name=>job_class.to_s, :parent=>self, :data=>7)
#      Delayed::Job.enqueue job_class.new(data, all_job_data, self.id, log) 
      q = Carrot.queue(job_class.to_s.underscore)
      q.publish(log.key);
    end
  end

  ## A callback so the child jobs can report in.
  def member_finished
puts "INVOKED on #{self.key}"
    ## Check to see if all children are finished.
    #if JobLogItem.find_by_index(:parent_id, self.id).in(:status=>['READY', 'PROCESSING', 'ENQUEUE']).count > 0
    if find_children_with_status(['READY', 'PROCESSING', 'ENQUEUE']).count > 0
      self.update_attribute(:status, "PROCESSING") if status != 'PROCESSING'
      return
    end
    if find_children_with_status(['FAILED']).count > 0
      self.update_attribute(:status, "FAILED") 
    else
      self.update_attribute(:status, "SUCCESS") 
    end
    
  end
end
