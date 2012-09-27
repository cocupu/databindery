class MappingTemplatesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :pool, :only=>[:create, :new], :find_by => :short_name, :through=>:identity
  load_and_authorize_resource :except=>[:create, :new]


  def new
    authorize! :create, MappingTemplate
    raise ArgumentError unless params[:mapping_template] && params[:mapping_template][:worksheet_id]
    @worksheet = Worksheet.find(params[:mapping_template][:worksheet_id])
    mappings = []
    header_row = @worksheet.rows[0] #this is a bad assumption
    header_row.values.each_with_index { |value, n| mappings << {:source=> (n+65).chr, :label => value }}
    @mapping_template = MappingTemplate.new(:model_mappings=>[{:field_mappings=>mappings}])
  end

  def create
    @worksheet = Worksheet.find(params[:worksheet_id])
    authorize! :create, MappingTemplate
    identity = current_user.identities.find_by_short_name(params[:identity_id])
    raise CanCan::AccessDenied.new "You can't create for that identity" if identity.nil?
    @mapping_template = MappingTemplate.new(owner: identity, pool: @pool)
    params[:mapping_template][:model_mappings_attributes].each do |key, mma|
      #remove template fields
      mma['field_mappings_attributes'].delete('new_field_mappings')
    end
    begin
      @mapping_template.attributes = params[:mapping_template]
    rescue ActiveRecord::RecordInvalid => e
      ## Model was invalid
      flash[:alert] = e.record.errors.full_messages.join("\n")
      render :action=>'new'
      return
    end
    @mapping_template.save!
    @worksheet.reify(@mapping_template, current_pool)
    redirect_to identity_pool_mapping_template_path(identity.short_name, @pool, @mapping_template)
  end

  def show
  end
end
