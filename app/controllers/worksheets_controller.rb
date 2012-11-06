class WorksheetsController < ApplicationController
  load_and_authorize_resource :pool, :find_by => :short_name, :through=>:identity


  def index
    spreadsheet = Bindery::Spreadsheet.find(params[:spreadsheet_id])
    @worksheets = spreadsheet.worksheets

    if @worksheets.size == 1
      redirect_to new_identity_pool_mapping_template_path(@identity.short_name, @pool, :mapping_template=>{:worksheet_id=>@worksheets.first.id})
      return
    end
  end
end
