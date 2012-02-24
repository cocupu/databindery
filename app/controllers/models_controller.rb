class ModelsController < ApplicationController
  def index
    @models = Model.list
  end
end
