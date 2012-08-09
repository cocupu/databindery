class NodesController < ApplicationController
  load_and_authorize_resource :model, :only=>:index
  load_and_authorize_resource :through => :model, :only=>:index
  load_and_authorize_resource :except=>:index

  def index
  end

  def new
    @node.binding = params[:binding]
  end
end
  
