class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
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
