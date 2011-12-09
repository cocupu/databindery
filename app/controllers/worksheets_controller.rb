class WorksheetsController < ApplicationController
  def index
    @spreadsheet = Cocupu::Spreadsheet.find(params[:spreadsheet_id])
  end
end
