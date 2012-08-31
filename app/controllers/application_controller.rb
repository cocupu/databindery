class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json do 
        if signed_in?
          message = "You don't have permission to #{exception.action} #{exception.subject.class.to_s.pluralize}"
          render :json=>{:status=>:error, :message=>message}, :status => :forbidden
        else
          message = "You must be logged in to do that!"
          render :json=>{:status=>:error, :message=>message}, :status => :unauthorized
        end
      end 
      format.html { redirect_to root_path, alert: exception.message }
    end
  end

  ## Just assuming the first identity for now.  Later we may allow the user to pick the identity they want to use.
  def current_identity
    return nil if current_user.nil?
    current_user.identities.first
  end

  ## Just assuming the first pool for now.  Later we may allow the user to pick the pool to use.
  def current_pool
    return nil if current_identity.nil?
    current_identity.pools.first
  end

  def current_ability
    @current_ability ||= Ability.new(current_identity)
  end
end
