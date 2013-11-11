class IdentitiesController < ApplicationController
  def index
    render :json=>current_user.identities.map {|i| {short_name: i.short_name, url: identity_pools_path(i)}}
  end
  def show
    if @identity.nil? && params[:id].to_i.to_s == params[:id]
      @identity = Identity.find(params[:id])
    else
      @identity = Identity.find_by_short_name(params[:id])
    end
    render :json=>@identity.as_json.reject {|k,v| k=="login_credential_id"}
  end
end
