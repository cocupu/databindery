class DrivesController < ApplicationController

  include GoogleAuthorization
  before_filter :authenticate_user!

  ##
  # Main entry point for the app. Ensures the user is authorized & inits the editor
  # for either edit of the opened files or creating a new file.
  def index 
    unless authorized?
      redirect_to auth_url(params[:state])
      return
    end

    result = api_client.execute!(:api_method => drive.files.list)
    @files = result.data.items
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
