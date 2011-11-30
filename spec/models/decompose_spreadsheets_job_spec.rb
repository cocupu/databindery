require 'spec_helper'


describe DecomposeSpreadsheetJob do
  it "should have perform" do
    @job = DecomposeSpreadsheetJob.new({:spreadsheet_id=>1234}, nil)
    @job.input[:spreadsheet_id].should == 1234
    @job.should respond_to :perform
  end

end
