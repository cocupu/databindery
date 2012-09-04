class DrivesController < ApplicationController

  include GoogleAuthorization
  before_filter :authenticate_user!
  layout 'full_width'

  ##
  # Main entry point for the app. Ensures the user is authorized & inits the editor
  # for either edit of the opened files or creating a new file.
  def index 
    if params[:code]
      authorize_code(params[:code])
    end	
    unless authorized?
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

    respond_to do |format|
      format.json do
        result = api_client.execute!(:api_method => drive.files.list)
        # a list of files. see https://developers.google.com/drive/v2/reference/files
        # TODO OPTIMIZE cache this result
        @files = result.data.items
        result = @files.map {|f| file_json(f) }
        render :json=>result 
      end
      format.html { redirect_to models_path(:anchor=>'drive') }
    end
  end

  ###
  # Load content
  #
  def show
    result = api_client.execute!(
      :api_method => drive.files.get,
      :parameters => { 'fileId' => params['id'] })
    file = result.data.to_hash
    result = api_client.execute(:uri => result.data.downloadUrl)
    file['content'] = result.body
    render json: file
  end

  private
  def file_json(file) 
    type = file.mime_type == 'application/vnd.google-apps.folder' ? 'folder' : 'file'
    date = file.modifiedDate > 1.day.ago ? file.modifiedDate.to_formatted_s(:time) : file.modifiedDate.to_formatted_s(:short)
    bindings = Node.find_all_by_binding(file.id).map(&:persistent_id) if type == 'file'
    { title: file.title, id: file.id, type: type, owner: file.userPermission.id, date: date, bindings: bindings, mime_type: file.mime_type }
  end
end
