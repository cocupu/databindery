class PoolsController < ApplicationController
  load_and_authorize_resource :find_by => :short_name, :through=>:identity

  layout 'full_width'

  def index
  end

  def show
    respond_to do |format|
      format.html do
        @models = @pool.models.accessible_by(current_ability) # for the js client
      end
      format.json { render :json=>@pool }
    end
  end

  def create
    @pool.name = params[:pool][:name]
    #@pool.description = params[:pool][:description]
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @pool.owner = identity
    @pool.save!
    respond_to do |format|
      format.json { render :json=>@pool}
    end
  end

  def update
    @pool.update_attributes(params[:pool])
    respond_to do |format|
      format.html { redirect_to identity_pool_path(@identity.short_name, @pool), :notice=>"#{@pool.name} updated" }
      format.json { head :no_content }
    end
  end
end
