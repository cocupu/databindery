class ChattelsController < ApplicationController

  def index
    @chattels = Chattel.find(:all)
  end 

  def new 
    @chattel = Chattel.new
  end

  def create
    @chattel = Chattel.new
    @chattel.attachment = params[:chattel][:attachment]
    @chattel.save!
    #TODO check to see if this is a valid spreadsheet.
    @log = JobLogItem.create(:status=>"READY", :name=>DecomposeSpreadsheetJob.to_s)
    Delayed::Job.enqueue DecomposeSpreadsheetJob.new(@chattel.id, @log)
    redirect_to describe_chattel_path(@chattel, :log=>@log.id)
  end

  def describe
    @log = JobLogItem.find(params[:log])
    @chattel= Chattel.find(params[:id])
  end
end
