require 'spec_helper'

describe WorksheetsController do
  describe 'a signed in user going to index' do
    before do
      cred = FactoryGirl.create :login_credential
      @pool = FactoryGirl.create(:pool, owner: cred.identities.first)
      sign_in cred
    end
    describe 'with multiple worksheets' do
      before do
        @worksheet1 = Worksheet.new
        @worksheet2 = Worksheet.new
        @spreadsheet = FactoryGirl.create(:spreadsheet, :worksheets=>[@worksheet1, @worksheet2])
      end
      it "should be success" do
        get :index, pool_id: @pool, spreadsheet_id: @spreadsheet
        response.should be_success
        assigns[:worksheets].should include(@worksheet1, @worksheet2)
      end
    end
    describe 'with a single worksheet' do
      before do
        @worksheet = Worksheet.new
        @spreadsheet = FactoryGirl.create(:spreadsheet, :worksheets=>[@worksheet])
      end
      it "should be success" do
        get :index, pool_id: @pool, spreadsheet_id: @spreadsheet
        response.should redirect_to new_pool_mapping_template_path(@pool, :mapping_template=>{:worksheet_id=>@worksheet.id}) 
      end
    end
  end
end
