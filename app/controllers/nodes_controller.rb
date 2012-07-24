class NodesController < ApplicationController
  def index
    @model = Model.find(params[:model_id])
  end
end
