class PoolsController < ApplicationController
  load_and_authorize_resource :find_by => :short_name, :through=>:identity, :except=>[:update, :create]

  layout 'full_width'

  def index
    respond_to do |format|
      format.html {}
      format.json { render :json=>@pools.map {|i| {short_name: i.short_name, url: identity_pool_path(i.owner, i)}} }
    end
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
    authorize! :create, Pool
    # Make sure they own the currently set identity.
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @pool = identity.pools.build(params.require(:pool).permit(:description, :name, :short_name))

    #@pool.name = params[:pool][:name]
    #@pool.description = params[:pool][:description]
    @pool.owner = identity
    @pool.save!
    respond_to do |format|
      format.json { render :json=>@pool}
    end
  end

  def update
    raise CanCan::AccessDenied.new if current_user.nil?
    # Make sure they own the currently set identity.
    identity = current_user.identities.where(:short_name=>params[:identity_id]).first!
    @pool = identity.pools.find_by_short_name(params[:id])
    authorize! :update, @pool
    @pool.update_attributes(params.require(:pool).permit(:description, :name, :short_name))
    respond_to do |format|
      format.html { redirect_to identity_pool_path(@identity.short_name, @pool), :notice=>"#{@pool.name} updated" }
      format.json { head :no_content }
    end
  end
end
