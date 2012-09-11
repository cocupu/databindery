class DrivesController < ApplicationController

  include GoogleAuthorization
  before_filter :authenticate_user!
  layout 'full_width'
  load_and_authorize_resource :pool, :except=>:index

  ##
  # Main entry point for the app. Ensures the user is authorized & inits the editor
  # for either edit of the opened files or creating a new file.
  def index 
    if params[:code]
      authorize_code(params[:code])
    end	
    unless authorized?
      self.current_pool = params[:pool_id] if params[:pool_id]
      respond_to do |format|
        format.json do
          render :status=>:unauthorized, :json=>{'redirect' => auth_url(params[:state])}
        end
        format.html do
          redirect_to auth_url(params[:state])
        end
      end
      return
    end

    if !params[:pool_id]
      redirect_to pool_drives_path(current_pool)
      return
    end

    respond_to do |format|
      format.json do
        result = api_client.execute!(:api_method => drive.files.list)
        # a list of files. see https://developers.google.com/drive/v2/reference/files
        # TODO OPTIMIZE cache this result
        @files = result.data.items
        result = @files.map {|f| file_json(f) }
        render :json=>result 
      end
      format.html { redirect_to pool_path(@pool, :anchor=>'drive') }
    end
  end

  ###
  # Load content
  def spawn
    result = api_client.execute!(
      :api_method => drive.files.get,
      :parameters => { 'fileId' => params['id'] })
    file = result.data
    result = api_client.execute(:uri => result.data.downloadUrl)

    # From ChattelsController#create
    if ['application/vnd.ms-excel', 'application/vnd.oasis.opendocument.spreadsheet'].include?(file.mime_type)
      @chattel = Cocupu::Spreadsheet.new
    else
      @chattel = Chattel.new
    end
    @chattel.owner = current_identity
    @chattel.save!
    # TODO save the original version id (from google drive)?
    @chattel.attach(result.body, file.mime_type, file.title)
    @chattel.save!
    #TODO check to see if this is a valid spreadsheet.
    @log = JobLogItem.create(:status=>"READY", :name=>DecomposeSpreadsheetJob.to_s, :data=>@chattel.id)
    q = Carrot.queue('decompose_spreadsheet')
    q.publish(@log.id);

    redirect_to describe_chattel_path(@chattel, :log=>@log.id)
  end

  private
  def file_json(file) 
    if file.mime_type == 'application/vnd.google-apps.folder' 
      type = 'folder'
    elsif ['application/vnd.ms-excel', 'application/vnd.oasis.opendocument.spreadsheet'].include?(file.mime_type)
      type = 'spreadsheet'
    else
      type = 'file'
    end
    date = file.modifiedDate > 1.day.ago ? file.modifiedDate.to_formatted_s(:time) : file.modifiedDate.to_formatted_s(:short)
    bindings = Node.find_all_by_binding(file.id).map(&:persistent_id) if type == 'file'
    { title: file.title, id: file.id, type: type, owner: file.userPermission.id, date: date, bindings: bindings, mime_type: file.mime_type }
  end
end
