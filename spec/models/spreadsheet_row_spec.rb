require 'spec_helper'

describe SpreadsheetRow do
  before do
    @row = SpreadsheetRow.new(:chattel_id => '999', :row_number => '9', :job_log_item_id => '7', :values => [nil, '4', '7'])
  end
  it "should have a spreadsheet_id" do
    @row.chattel_id.should == '999'
  end
  it "should have a row number" do
    @row.row_number.should == '9'
  end
  it "should have a job number" do
    @row.job_log_item_id.should == '7'
  end

  it "should have an array of values" do
    @row.values.should == [nil, '4', '7']
  end
end
