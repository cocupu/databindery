class ProcessChain
  include Mongoid::Document
  field :status
  field :current_step

  after_initialize :init_status

  def start 
    self.status = "PROCESSING"
    self.current_step = self.steps.first
    run_step(current_step)
    self.save!
  end

  def increment_step!(last_step_output = nil)
    raise "IllegalState: can't increment step unless status is 'PROCESSING'" unless self.status == "PROCESSING"
    next_index = steps.index(self.current_step) + 1
    if steps.length == next_index
      self.status = "DONE"
      self.current_step = nil
    else
      self.current_step =steps[next_index]
      run_step(current_step, last_step_output)
    end
    self.save!
  end

  private
  def run_step(step, last_step_output=nil)
    raise "invalid step" if step.nil?
    ### NEED to provide input & a pointer to this chain
    (step+'Job').constantize.new(input, last_step_output)
  end
  def init_status
    self.status = "READY"
  end

end
