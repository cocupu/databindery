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
    log = JobLogItem.create(:status=>"READY", :name=>self.class.to_s)
    Delayed::Job.enqueue DecomposeSpreadsheetJob.new(@chattel.id, log)
    redirect_to describe_chattel_path(@chattel)
  end

  def describe
    @chattel= Chattel.find(params[:id])
  end
end
