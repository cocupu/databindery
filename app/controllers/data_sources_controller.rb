class DataSourcesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' && c.request.params.include?(:auth_token) }

  load_and_authorize_resource :pool, :only=>[:create, :index], :find_by => :short_name

  def index
    @s3_connections = S3Connection.where(pool_id: @pool.id)
    
    respond_to do |format|
      format.html {}
      format.json do
        render :json=>serialize_all_sources
        # render :json=>@s3_connections.map { |ds| serialize_data_source(ds) }
      end
    end
  end 
  
  private
  def serialize_all_sources
    json = {}
    json["s3Connections"] = @s3_connections.map { |ds| serialize_data_source(ds) }
    json.as_json
  end
  
  def serialize_data_source(ds)
    json = ds.as_json
    json.merge!(:url => identity_pool_s3_connection_path(identity_id: current_identity, pool_id: @pool, id: ds.id)) if ds.kind_of?(S3Connection)
    json
  end
end
