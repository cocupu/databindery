require 'spec_helper'

describe Worksheet do
  it "should have a name" do
    @ws = Worksheet.new(:name=>"Fred")
    @ws.name.should == 'Fred'
  end
  it "should belong to a spreadsheet" do
    @spreadsheet = Cocupu::Spreadsheet.create
    @ws = Worksheet.new(:name=>"Fred")
    @spreadsheet.worksheets= [@ws]
    @spreadsheet.worksheets.first.should == @ws
    
  end
  it "should have many rows" do
    @ws = Worksheet.create(:name=>"Fred")
    @row = SpreadsheetRow.new()
    @ws.rows= [@row]
    @ws.rows.first.should == @row
   
  end
  it "reify should initiate a ConcurrentJob" do
    template = mock("template")
    ws = Worksheet.new()
    job = mock("job")
    job.expects(:enqueue_collection).with(ReifyEachSpreadsheetRowJob, [], {:template=>template})
    ConcurrentJob.expects(:create).returns(job)
    ws.reify(template)
  end

end