class SpreadsheetRowsController < ApplicationController
  def show
    @spreadsheet_rows = Worksheet.find(params[:id]).rows
  end
end
