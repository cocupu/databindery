require 'spec_helper'

describe Cocupu::Spreadsheet do
  it "should have worksheets" do
    ss = Cocupu::Spreadsheet.new()
    ws = Worksheet.new()
    ss.worksheets << ws
    ss.worksheets.should include ws
  end

end
