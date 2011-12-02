require 'spec_helper'


describe DecomposeSpreadsheetJob do
  it "should have perform" do
    @job = DecomposeSpreadsheetJob.new({:spreadsheet_id=>1234}, nil)
    @job.input[:spreadsheet_id].should == 1234
    @job.should respond_to :perform
  end

  it "should break up the spreadsheet" do
    @chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls'))
    @job = DecomposeSpreadsheetJob.new({:spreadsheet_id=>@chattel.id}, nil)
    @job.enqueue(@job) #start the logger
    @job.perform
  end
end
