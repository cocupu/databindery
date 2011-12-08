class ConcurrentJob < JobLogItem

  after_initialize :init_fields

  def init_fields
    return unless new_record?
    self.status = "READY"
    self.name = self.class.to_s
  end
  

  def enqueue_collection(job_class, per_job_data, all_job_data)
    self.update_attribute(:status, "PROCESSING")
    per_job_data.each do |data|
      log = JobLogItem.create(:status=>"READY", :name=>job_class.to_s, :parent=>self)
      Delayed::Job.enqueue job_class.new(data, all_job_data, self.id, log) 
    end
  end

  ## A callback so the child jobs can report in.
  def member_finished
    ## Check to see if all children are finished.
    if JobLogItem.where(:parent_id => self.id).in(:status=>['READY', 'PROCESSING', 'ENQUEUE']).count > 0
      self.update_attribute(:status, "PROCESSING") if status != 'PROCESSING'
      return
    end
    if JobLogItem.where(:parent_id => self.id, :status=>'FAILED').count > 0
      self.update_attribute(:status, "FAILED") 
    else
      self.update_attribute(:status, "SUCCESS") 
    end
    
  end
end
