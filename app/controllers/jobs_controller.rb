class JobsController < ApplicationController
  def index
    @jobs = Delayed::Backend::Mongoid::Job.find(:all)
    @job_logs = JobLogItem.find(:all)
  end
end
