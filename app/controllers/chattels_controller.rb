class ChattelsController < ApplicationController

  def index
    @chattels = Chattel.all
  end 

  def new 
    @chattel = Chattel.new
  end

  def describe
    @log = JobLogItem.find(params[:log])
    @chattel= Chattel.find(params[:id])
  end

  private 
  def detect_type(chattel)
    case chattel.attachment_content_type
    when "application/vnd.ms-excel"
      Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      Openoffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
    
  end
end
