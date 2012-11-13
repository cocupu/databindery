class PoolsController < ApplicationController
  load_resource :identity, :find_by => :short_name, :only=>[:index, :show]
  load_and_authorize_resource :find_by => :short_name, :through=>:identity, :only=>:show

  def index
    ### This query finds all the pools belonging to @identity that can be seen by current_identity
    @pools = Pool.for_identity(current_identity).where(:owner_id => @identity)
    respond_to do |format|
      format.html {}
      format.json { render :json=>@pools.map {|i| {short_name: i.short_name, url: identity_pool_path(i.owner, i)}} }
    end
  end

  def show
    authorize! :show, @pool
    respond_to do |format|
      format.html do
        @models = @pool.models + [Model.file_entity]
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
    @pool.access_controls = []
    params[:pool][:access_controls].each do |ac|
      ident = Identity.where(short_name: ac[:identity]).first
      next if !ident or !['EDIT', 'READ'].include?(ac[:access]) ## TODO add error?
      @pool.access_controls.build identity: ident, access: ac[:access]
    end
    @pool.update_attributes(params.require(:pool).permit(:description, :name, :short_name))
    respond_to do |format|
      format.html { redirect_to identity_pool_path(@identity.short_name, @pool), :notice=>"#{@pool.name} updated" }
      format.json { head :no_content }
    end
  end
end
