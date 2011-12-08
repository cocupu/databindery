class JobsController < ApplicationController
  def index
    @jobs = Delayed::Backend::Mongoid::Job.find(:all)
    @job_logs = JobLogItem.where(:parent_id => nil)
  end
end
