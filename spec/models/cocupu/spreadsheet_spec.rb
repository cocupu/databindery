require 'spec_helper'

describe Cocupu::Spreadsheet do
  it "should have rows" do
    ss = Cocupu::Spreadsheet.new()
    ss_row = SpreadsheetRow.new()
    ss.rows << ss_row
    ss.rows.should include ss_row
  end

  it "reify should initiate a ConcurrentJob" do
    template = mock("template")
    ss = Cocupu::Spreadsheet.new()
    job = mock("job")
    job.expects(:enqueue_collection).with(SpreadsheetLineReifyJob, [], {:template=>template})
    ConcurrentJob.expects(:new).returns(job)
    ss.reify(template)
  end
end
