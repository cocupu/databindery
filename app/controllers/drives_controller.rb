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
      redirect_to auth_url(params[:state])
      return
    end

    result = api_client.execute!(:api_method => drive.files.list)
    # a list of files. see https://developers.google.com/drive/v2/reference/files
    # TODO OPTIMIZE cache this result
    items = result.data.items
    @files = items
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
