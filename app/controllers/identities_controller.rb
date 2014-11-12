class IdentitiesController < ApplicationController
  def index
    if params[:q]
      q = params[:q]
      if q == "current_user"
        @identities = Identity.where(:login_credential_id => current_user.id)
      else
        capitalized = q.split.map(&:capitalize).join(' ')
        @identities = Identity.where("name LIKE :prefix OR name LIKE :capitalized OR short_name LIKE :prefix OR short_name LIKE :capitalized", prefix: "%#{q}%", capitalized:"%#{capitalized}%").limit(25)
      end
    else
      @identities = Identity.limit(25)
    end
    render :json=> @identities.map {|i| serialize_identity(i) }
  end
  def show
    if @identity.nil? && params[:id].to_i.to_s == params[:id]
      @identity = Identity.find(params[:id])
    else
      @identity = Identity.find_by_short_name(params[:id])
    end
    render :json=>serialize_identity(@identity)
  end

  private
  def serialize_identity(identity)
    identity.as_json.reject {|k,v| k=="login_credential_id"}.merge({url: identity_pools_path(identity)})
  end
end
