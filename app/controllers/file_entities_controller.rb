class FileEntitiesController < ApplicationController
  load_and_authorize_resource :class=>'Node', :find_by => :persistent_id
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_resource :target_node, :class => Node, :find_by => :persistent_id, :only=>[:new, :create]
  

  def create
    # @file_entity.binding = params[:binding]
    # @file_entity.model = Model.file_entity
    # @file_entity.pool = @pool
    # @file_entity.save!
    #  file_entity = FileEntity.register( params.permit(:pool, :data, :associations, :binding) )
    process_s3_direct_upload_params
    @file_entity = FileEntity.register(@pool, params.permit(:binding, :data, :associations))
    @target_node.files << @file_entity.persistent_id unless @target_node.nil?
    render :json=>@file_entity
  end
  
  def new
    # Only return the target node if current user can edit it.
    @target_node = nil unless can?(:edit, @target_node)
    bucket = @pool.ensure_bucket_initialized
    @pool.default_file_store.ensure_cors_for_uploads(bucket.name)
    S3DirectUpload.config.bucket = bucket.name
  end
  
  def process_s3_direct_upload_params
    if params[:data].nil? && !params[:url].nil?
      params[:data] = params.slice(:storage_location_id, :file_name, :file_size, :content_type)
      params[:data]["storage_location_id"] = params["filepath"] unless params["filepath"].nil? 
      params[:data]["file_name"] = params["filename"] unless params["filename"].nil? 
      params[:data]["file_size"] = params["filesize"] unless params["filesize"].nil?      
      params[:data]["content-type"] = params["filetype"] unless params["filetype"].nil?      
    end
  end
end
