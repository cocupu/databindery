class JobsController < ApplicationController
  def index
    @job_logs = JobLogItem.all
  end
end
