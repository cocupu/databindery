class WorksheetsController < ApplicationController
  def index
    spreadsheet = Cocupu::Spreadsheet.find(params[:spreadsheet_id])
    @worksheets = spreadsheet.worksheets
    if @worksheets.size == 1
      redirect_to new_mapping_template_path(:mapping_template=>{:worksheet_id=>@worksheets.first.id})
      return
    end
  end
end
