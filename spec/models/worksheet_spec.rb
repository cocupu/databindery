require 'spec_helper'

describe Worksheet do
  it "should have a name" do
    @ws = Worksheet.new(:name=>"Fred")
    @ws.name.should == 'Fred'
  end
  it "should have an order" do
    @ws = Worksheet.new(:order=>3)
    @ws.order.should == 3
  end
  it "should belong to a spreadsheet" do
    @spreadsheet = Bindery::Spreadsheet.create
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
  it "reify should initiate a ConcurrentJob but not enqueue header rows" do
    template = MappingTemplate.create!(owner: FactoryGirl.create(:identity), row_start: 2)
    pool = FactoryGirl.create :pool
    ws = Worksheet.new()
    ws.stub(:rows => ['one', 'two', 'three'])
    job = double("job")
    job.should_receive(:enqueue_collection).with(ReifyEachSpreadsheetRowJob, ['two', 'three'], {:template_id=>template.id, :pool_id=>pool.id})
    ConcurrentJob.should_receive(:create).and_return(job)
    ws.reify(template, pool)
  end
end
