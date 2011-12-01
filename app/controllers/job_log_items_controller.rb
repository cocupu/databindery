class JobLogItemsController < ApplicationController
  def show 
    @job_log_item = JobLogItem.find(params[:id])
  end
end
