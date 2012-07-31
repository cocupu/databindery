class NodesController < ApplicationController
  # load_and_authorize_resource :model
  # load_and_authorize_resource :through => :model
  def index
    @model = Model.find(params[:model_id])
    # authorize! :show, @model
  end
end
