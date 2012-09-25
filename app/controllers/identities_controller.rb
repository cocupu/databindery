class IdentitiesController < ApplicationController
  def index
    render :json=>current_user.identities.map {|i| {short_name: i.short_name, url: identity_pools_path(i)}}
  end
end
