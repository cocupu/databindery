require 'spec_helper'

describe WorksheetsController do
  describe 'index' do
    before do
      @spreadsheet = Cocupu::Spreadsheet.create!()
    end
    it "should be success" do
      get :index, :spreadsheet_id => @spreadsheet.id
      assigns[:spreadsheet].should == @spreadsheet
      response.should be_success
    end
  end

end
