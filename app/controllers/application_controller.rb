class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_identity
  
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
    session[:pool_id] ? Pool.find(session[:pool_id]) : current_user.identities.first.pools.first
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
end
