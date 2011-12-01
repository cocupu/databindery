class SpreadsheetRowsController < ApplicationController
  def show
    @spreadsheet_rows = SpreadsheetRow.all(:conditions=>{:chattel_id => params[:id]})
  end
end
