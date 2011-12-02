class ConcurrentJob
  include Mongoid::Document
  field :status

  after_initialize :init_status

  def init_status
    self.status = "READY"
  end

  
  def enqueue_jobs(job_class, per_job_data, all_job_data)
    self.update_attribute(:status, "PROCESSING")
    per_job_data.each do |data|
      Delayed::Job.enqueue job_class.new(data, all_job_data, self.id) 
    end
  end

  ## A callback so the child jobs can report in.
  def member_finished
    ## Check to see if all children are finished.
    
  end
end
