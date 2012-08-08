require 'google/api_client/client_secrets'
class DrivesController < ApplicationController
  rescue_from Google::APIClient::ServerError do |e|
  end
  ##
  # For /svc methods, assume client errors are due to auth failures
  # and return a redirect (via JSON)
  rescue_from Google::APIClient::ClientError do
    response = {
      'redirect' => auth_url('{}')
    }
    render json: response
  end


  SCOPES = [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile'
  ]
  
  ##
  # Get an API client instance
  def api_client
    @client ||= (begin
      client = Google::APIClient.new

      client.authorization.client_id = credentials.client_id
      client.authorization.client_secret = credentials.client_secret
      client.authorization.redirect_uri = credentials.redirect_uris.first
      client.authorization.scope = SCOPES
      client
    end)
  end

  def authorized?
    return api_client.authorization.refresh_token && api_client.authorization.access_token
  end

  before_filter do
    # Make sure access token is up to date for each request
    api_client.authorization.update_token!(session)
    if api_client.authorization.refresh_token && api_client.authorization.expired?
      api_client.authorization.fetch_access_token!
    end
  end

  after_filter do
      # Serialize the access/refresh token to the session
      session[:access_token] = api_client.authorization.access_token
      session[:refresh_token] = api_client.authorization.refresh_token
      session[:expires_in] = api_client.authorization.expires_in
      session[:issued_at] = api_client.authorization.issued_at
  end

  ##
  # Upgrade our authorization code when a user launches the app from Drive &
  # ensures saved refresh token is up to date
  def authorize_code(authorization_code)
    api_client.authorization.code = authorization_code
    api_client.authorization.fetch_access_token!

    result = api_client.execute!(:api_method => oauth2.userinfo.get)
    user = User.find_or_create_by_profile_id(result.data.id)
    if user.new_record?
      user.email = result.data.email
    end
    api_client.authorization.refresh_token = (api_client.authorization.refresh_token || user.refresh_token)
    if user.refresh_token != api_client.authorization.refresh_token
      user.refresh_token = api_client.authorization.refresh_token
      user.save
    end
    session[:user_id] = user.id
  end

  def auth_url(state = '')
    user_email = current_user ? current_user.email : ''
    return api_client.authorization.authorization_uri(
      :state => state,
      :approval_prompt => :force,
      :access_type => :offline,
      :user_id => user_email
    ).to_s
  end

  ##
  # Prepare request data for upload
  def prepare_data(body)
    data = MultiJson.decode(body)
    resource_id = data['resource_id']
    file_content = nil

    if data['content']    
      content = StringIO.new(data['content'])
      file_content = Google::APIClient::UploadIO.new(content, data['mimeType'])
    end
    data.keep_if { |k,v| %w{title labels parents description mimeType}.include? k}
    
    [resource_id, data, file_content]
  end

  ##
  # Main entry point for the app. Ensures the user is authorized & inits the editor
  # for either edit of the opened files or creating a new file.
  def index 
    if params[:code]
      authorize_code(params[:code])
    elsif params[:error] # User denied the oauth grant
      render :text=>"Forbidden", :status => :forbidden
    end
    unless authorized?
      redirect_to auth_url(params[:state])
      return
    end

    if params[:state] || params[:code]
      # state = MultiJson.decode(params[:state] || '{}')
      # if state['parentId']
      #   redirect to("/#/create/#{state['parentId']}")
      # else
      #   doc_id = state['ids'] ? state['ids'].first : ''
      #   redirect to("/#/edit/#{doc_id}")
      # end
    end
    render :text=>"logged in"
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
  
  def credentials
   @credentials ||= Google::APIClient::ClientSecrets.load
  end

  def client
    @client ||= Google::APIClient.new
  end

  def drive
    @drive ||= client.discovered_api('drive', 'v2')
  end
  def oauth2
    @oauth2 ||= client.discovered_api('oauth2', 'v2')
  end

end
