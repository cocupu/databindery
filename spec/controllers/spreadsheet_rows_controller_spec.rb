require 'spec_helper'

describe SpreadsheetRowsController do

  describe "show" do
    before do
      @ss_row = SpreadsheetRow.create(:chattel_id=>'77')
    end
    it "should be successful" do
      get :show, :id=>'77'
      response.should be_success
      assigns[:spreadsheet_rows].should include @ss_row
    end
  end

end
