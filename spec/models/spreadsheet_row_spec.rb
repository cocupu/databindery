require 'spec_helper'

describe SpreadsheetRow do
  before do
    @job = JobLogItem.create!
    @row = SpreadsheetRow.new(:row_number => '9', :job_log_item => @job)
    @row.values = [nil, 'str', 7]
  end
  it "should have a row number" do
    @row.row_number.should == 9
  end
  it "should have a job number" do
    @row.job_log_item.should == @job
  end

  it "should serialize an array of values" do
    @row.save!
    @row.reload
    @row.values.should == [nil, 'str', 7]
  end
end
