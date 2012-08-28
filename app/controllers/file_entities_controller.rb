class FileEntitiesController < ApplicationController
  load_and_authorize_resource :class=>'Node', :find_by => :persistent_id

  def create
    @file_entity.binding = params[:binding]
    @file_entity.model = Model.file_entity(current_identity)
    @file_entity.pool = current_pool
    @file_entity.save!
    render :json=>@file_entity
  end
end
