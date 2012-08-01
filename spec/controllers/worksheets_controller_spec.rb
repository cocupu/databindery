require 'spec_helper'

describe WorksheetsController do
  describe 'index with multiple worksheets' do
    before do
      @worksheet1 = Worksheet.new
      @worksheet2 = Worksheet.new
      @spreadsheet = Cocupu::Spreadsheet.create!(:worksheets=>[@worksheet1, @worksheet2])
    end
    it "should be success" do
      get :index, :spreadsheet_id => @spreadsheet.id
      assigns[:worksheets].should include(@worksheet1, @worksheet2)
      response.should be_success
    end
  end
  describe 'index with a single worksheet' do
    before do
      @worksheet = Worksheet.new
      @spreadsheet = Cocupu::Spreadsheet.create!(:worksheets=>[@worksheet])
    end
    it "should be success" do
      get :index, :spreadsheet_id => @spreadsheet.id
      response.should redirect_to new_mapping_template_path(:mapping_template=>{:worksheet_id=>@worksheet.id}) 
    end
  end

end
