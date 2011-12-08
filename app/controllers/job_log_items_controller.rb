class JobLogItemsController < ApplicationController
  def show 
    @job_log_item = JobLogItem.find(params[:id])
    @children = @job_log_item.children if @job_log_item.kind_of? ConcurrentJob
    respond_to do |format|
      format.json { render :json=>@job_log_item }
      format.html
    end
  end
end
