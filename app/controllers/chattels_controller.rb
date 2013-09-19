class ChattelsController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :pool, :only=>[:describe], :find_by => :short_name, :through=>:identity

  
  def index
    @chattels = Chattel.all
  end 

  def new 
    @chattel = Chattel.new
  end

  def describe
    @log = JobLogItem.find(params[:log])
  end

  private 
  def detect_type(chattel)
    case chattel.attachment_content_type
    when "application/vnd.ms-excel"
      Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      OpenOffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
    
  end
end
