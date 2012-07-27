class ApplicationController < ActionController::Base
  protect_from_forgery

  ## Just assuming the first identity for now.  Later we may allow the user to pick the identity they want to use.
  def current_identity
    current_user.identities.first
  end

  ## Just assuming the first pool for now.  Later we may allow the user to pick the pool to use.
  def current_pool
    current_identity.pools.first
  end
end
