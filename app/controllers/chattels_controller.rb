class ChattelsController < ApplicationController

  def index
    @chattels = Chattel.all
  end 

  def new 
    @chattel = Chattel.new
  end

  def create
    if ['application/vnd.ms-excel', 'application/vnd.oasis.opendocument.spreadsheet'].include?(params[:chattel][:attachment].content_type)
      @chattel = Cocupu::Spreadsheet.new
    else
      @chattel = Chattel.new
    end
    @chattel.attachment = params[:chattel][:attachment]
    @chattel.save!
    #TODO check to see if this is a valid spreadsheet.
    @log = JobLogItem.create(:status=>"READY", :name=>DecomposeSpreadsheetJob.to_s, :data=>@chattel.id)
    q = Carrot.queue('decompose_spreadsheet')
    q.publish(@log.id);

    redirect_to describe_chattel_path(@chattel, :log=>@log.id)
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
