class JobsController < ApplicationController
  def index
    #@job_logs = JobLogItem.find_by_index(:parent_id, nil)
    @job_logs = JobLogItem.list()
  end
end
