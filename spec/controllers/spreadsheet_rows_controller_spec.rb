require 'spec_helper'

describe SpreadsheetRowsController do

  describe "show" do
    before do
      @worksheet = Worksheet.new()
      @ss_row = SpreadsheetRow.create()
      @worksheet.rows << @ss_row
      @worksheet.save
    end
    it "should be successful" do
      get :show, :id=>@worksheet.id
      response.should be_success
      assigns[:spreadsheet_rows].should include @ss_row
    end
  end

end
