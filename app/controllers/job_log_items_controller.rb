class JobLogItemsController < ApplicationController
  def show 
    @job_log_item = JobLogItem.find(params[:id])
    respond_to do |format|
      format.json { render :json=>@job_log_item }
      format.html
    end
  end
end
