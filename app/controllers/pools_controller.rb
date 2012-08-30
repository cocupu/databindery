class PoolsController < ApplicationController
  load_and_authorize_resource

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
    @pool.owner = current_identity
    @pool.save!
    respond_to do |format|
      format.json { render :json=>@pool}
    end
  end
end
