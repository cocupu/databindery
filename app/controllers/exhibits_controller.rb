class ExhibitsController < ApplicationController

  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :through=>:pool, :except=>:create

  
  def index
  end

  def edit
    @fields = @pool.all_fields
  end


  # def show
  #   # Constrain results to this pool
  #   # (@response, @facet_fields) = get_search_results( params, {:qf=>(query_fields + ["pool"]).join(' '), :qt=>'search', 'facet.field' => facets})
  #   # 
  #   # @total = @response["numFound"]
  #   # @results = Node.find(@response['docs'].map{|d| d['version']})

  #   # TODO constrain to current pool
  #   puts "getting search results"
  #   (@response, @document_list) = get_search_results
  #   @filters = params[:f] || []
  #   
  #   respond_to do |format|
  #     format.html { save_current_search_params }
  #   end

  # end

  def new
    @fields = @pool.all_fields
  end

  def create
    authorize! :create, Exhibit
    @exhibit = Exhibit.new(params.require(:exhibit).permit(:title, :facets, :index_fields))
    @exhibit.pool = @pool
    @exhibit.save
    redirect_to identity_exhibit_path(@identity.short_name, @exhibit), :notice=>"Exhibit created"
  end

  def update
    @exhibit.update_attributes(params.require(:exhibit).permit(:title, :facets, :index_fields))
    redirect_to identity_exhibit_path(@identity.short_name, @exhibit), :notice=>"Exhibit updated"
  end


end
