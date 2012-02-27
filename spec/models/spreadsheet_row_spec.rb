require 'spec_helper'

describe SpreadsheetRow do
  before do
    @job = JobLogItem.create()
    @row = SpreadsheetRow.new(:row_number => '9', :job_log_item => @job)
    @row.values = [nil, '4', '7'].map {|v| SpreadsheetRow::Value.new(:value=>v)}
  end
  it "should have a row number" do
    @row.row_number.should == 9
  end
  it "should have a job number" do
    @row.job_log_item.should == @job
  end

  it "should have an array of values" do
    @row.values.map(&:value).should == [nil, '4', '7']
  end
end
