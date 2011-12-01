require 'spec_helper'

describe SpreadsheetRowsController do

  describe "index" do
    before do
      @ss_row = SpreadsheetRow.create()
    end
    it "should be successful" do
      get :index
      response.should be_success
      assigns[:spreadsheet_rows].should include @ss_row
    end
  end

end
