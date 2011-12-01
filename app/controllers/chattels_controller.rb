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
    Delayed::Job.enqueue DecomposeSpreadsheetJob.new(:spreadsheet_id=>@chattel.id)
    redirect_to describe_chattel_path(@chattel)
  end

  def describe
    @chattel= Chattel.find(params[:id])
  end
end
