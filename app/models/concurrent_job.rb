class ConcurrentJob < JobLogItem

  #after_initialize :init_fields
  def initialize(*args)
    super(*args)
    init_fields
  end

  def init_fields
    return unless new_record?
    self.status = "READY"
    self.name = self.class.to_s
  end
  

  def enqueue_collection(job_class, per_job_data, all_job_data)
    self.status = "PROCESSING"
    save!
    per_job_data.each do |data|
      log = JobLogItem.new(:status=>"READY", :name=>job_class.to_s, :data=>data)
      log.parent = self
      log.save!
      ###Typically ReifyEachSpreadsheetRow job
      job_class.new(data, all_job_data, log).enqueue
      q = Carrot.queue(job_class.to_s.underscore)
      q.publish(log.id);
    end
  end

  ## A callback so the child jobs can report in.
  def member_finished
    ## Check to see if all children are finished.
    if count_children_with_status(['READY', 'PROCESSING', 'ENQUEUE']) > 0
      self.update_attributes(:status => "PROCESSING") if status != 'PROCESSING'
      return
    end
    if count_children_with_status(['FAILED']) > 0
      self.update_attributes(:status => "FAILED") 
    else
      self.update_attributes(:status => "SUCCESS") 
    end
    
  end
end
