class ApplicationController < ActionController::Base
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery

  before_filter :load_identity
  after_filter :set_csrf_cookie_for_ng
  respond_to :html, :json
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json do 
        if signed_in?
          logger.debug "permission denied #{exception.action} #{exception.subject}"
          message = exception.message
          message = "You don't have permission to #{exception.action} #{exception.subject.class.to_s.pluralize}" if message.empty?
          render :json=>{:status=>:error, :message=>message}, :status => :forbidden
        else
          logger.debug "Not logged in"
          message = "You must be logged in to do that!"
          render :json=>{:status=>:error, :message=>message}, :status => :unauthorized
        end
      end 
      format.html do 
        logger.debug "permission denied #{exception.action} #{exception.subject}"
        redirect_to root_path, alert: exception.message
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render :file => "public/404", :status => :not_found }
      format.json { render :json=>{:status=>:error, :message=>"Resource not found"}, :status => :not_found }
    end
  end

  def load_identity
    if params[:identity_id]
      @identity = Identity.find_by_short_name(params[:identity_id])
      # TODO check if can-read?
    end
  end

  ## Just assuming the first pool for now.  Later we may allow the user to pick the pool to use.
  def current_pool
    return nil if current_user.nil?
    session[:pool_id] ? Pool.where(:short_name=>session[:pool_id]) : current_user.identities.first.pools.first
  end

  def current_pool= (pool_id)
    session[:pool_id] = pool_id
  end

  def current_ability
    @current_ability ||= Ability.new(current_identity)
  end

  def current_identity
    current_user.identities.first if current_user
  end
  
  private
  
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token #if protect_against_forgery?
  end
  
  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
  
  
end
