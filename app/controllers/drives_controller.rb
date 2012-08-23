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

    result = api_client.execute!(:api_method => drive.files.list)
    # a list of files. see https://developers.google.com/drive/v2/reference/files
    # TODO OPTIMIZE cache this result
    @files = result.data.items
    respond_to do |format|
      format.json do
        # TODO put this in a method
        result = @files.map {|f| { title: f.title, owner: f.userPermission.id, date: f.modifiedDate > 1.day.ago ? f.modifiedDate.to_formatted_s(:time) : f.modifiedDate.to_formatted_s(:short), bindings: Node.find_all_by_binding(f.id).map(&:persistent_id) }}
        render :json=>result 
      end
      format.html {}
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


end
