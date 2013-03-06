class FileEntitiesController < ApplicationController
  load_and_authorize_resource :class=>'Node', :find_by => :persistent_id
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_resource :target_node, :class => Node, :find_by => :persistent_id, :only=>[:new, :create]
  

  def create
    @file_entity.binding = params[:binding]
    @file_entity.model = Model.file_entity
    @file_entity.pool = @pool
    @file_entity.save!
    render :json=>@file_entity
  end
  
  def new
    # Only return the target node if current user can edit it.
    @target_node = nil unless can?(:edit, @target_node)
    bucket = @pool.ensure_bucket_initialized
    @pool.default_file_store.ensure_cors_for_uploads(bucket.name)
    S3DirectUpload.config.bucket = bucket.name
  end
end
