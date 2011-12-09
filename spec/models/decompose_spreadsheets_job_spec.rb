require 'spec_helper'


describe DecomposeSpreadsheetJob do
  it "should have perform" do
    
    @job = DecomposeSpreadsheetJob.new(1234, nil)
    @job.spreadsheet_id.should == 1234
    @job.should respond_to :perform
  end

  it "should break up the Excel spreadsheet" do
    @chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls'))
    @job = DecomposeSpreadsheetJob.new(@chattel.id, JobLogItem.new)
    @job.enqueue(@job) #start the logger
    @job.perform
    sheets = Worksheet.where(:spreadsheet_id=>@chattel.id)
    sheets.count.should == 1
    SpreadsheetRow.where(:worksheet_id=>sheets.first.id).count.should == 434
  end
  it "should break up the ODS spreadsheet" do
    @chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/Stock Check 2.ods'))
    @job = DecomposeSpreadsheetJob.new(@chattel.id, JobLogItem.new)
    @job.enqueue(@job) #start the logger
    @job.perform
    sheets = Worksheet.where(:spreadsheet_id=>@chattel.id)
    sheets.count.should == 4
    SpreadsheetRow.where(:worksheet_id=>sheets.first.id).count.should == 39

    aluminum = SpreadsheetRow.where(:worksheet_id=>sheets[1].id, :row_number=>3).first
    aluminum.values.should == 
      ["Aluminium",
       "transportation, packaging, construction, electronics",
       75000000000.0,
       "Figure is for bauxite which is the current source for aluminium production",
       41400000.0,
       "Smelter production.",
       nil,
       nil,
       nil,
       nil,
       24000000.0,
       24400000.0,
       25900000.0,
       27700000.0,
       29800000.0,
       31900000.0,
       33700000.0,
       38000000.0,
       39000000.0,
       37300000.0,
       41400000.0,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       nil,
       "USGS",
       "http://minerals.usgs.gov/minerals/pubs/commodity/aluminum/",
       nil,
       nil]
  end
end
