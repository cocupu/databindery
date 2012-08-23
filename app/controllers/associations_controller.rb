class AssociationsController < ApplicationController
  load_and_authorize_resource :model, :only=>:create
  load_and_authorize_resource :node, :only=>[:index, :create], :find_by => :persistent_id
  def create
    if @model
      params[:association][:label] = params[:association][:name].capitalize
      @model.associations << params[:association]
      @model.save!
      redirect_to edit_model_path(@model)
    elsif @node
      association = @node.associations[params[:name]] || []
      association << params[:target_id]
      @node.associations[params[:name]] = association
      @node.save

      render :text=>'ok'
    end
  end

  def index
    model = @node.model
puts "NOde is: #{@node.inspect}"
puts "Id: #{params[:node_id]}"
    associations = {}
    model.associations.map{|a| a[:name]}.each do |assoc_name|
      associations[assoc_name] = []
      if @node.associations[assoc_name]
        @node.associations[assoc_name].each do |id|
puts "Finding ID: #{id}"
          associations[assoc_name] <<  Node.find_by_persistent_id(id).association_display
        end
      end
      associations['undefined'] = []
      if @node.associations['undefined']
        @node.associations['undefined'].each do |id| 
          associations['undefined'] << Node.find_by_persistent_id(id).association_display
        end
      end
    end
    respond_to do |format|
      format.json do
        render json: associations.to_json()
      end
    end
  end
end
