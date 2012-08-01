class NodesController < ApplicationController
  load_and_authorize_resource :model
  load_and_authorize_resource :through => :model
  def index
  end
end
