class ChattelsController < ApplicationController

  def new 
    @chattel = Chattel.new
  end

  def create
    @chattel = Chattel.new
    @chattel.attachment = params[:chattel][:attachment]
    @chattel.save!
    #TODO check to see if this is a valid spreadsheet.
    redirect_to describe_chattel_path(@chattel)
  end

  def describe
    @chattel= Chattel.find(params[:id])
  end
end
