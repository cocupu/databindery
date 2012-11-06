class FileEntitiesController < ApplicationController
  load_and_authorize_resource :class=>'Node', :find_by => :persistent_id
  load_and_authorize_resource :pool, :only=>:create

  def create
    @file_entity.binding = params[:binding]
    @file_entity.model = Model.file_entity
    @file_entity.pool = @pool
    @file_entity.save!
    render :json=>@file_entity
  end
end
