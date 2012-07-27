require 'spec_helper'


describe DecomposeSpreadsheetJob do
  it "should have perform" do
    
    @job = DecomposeSpreadsheetJob.new(1234, nil)
    @job.spreadsheet_id.should == 1234
    @job.should respond_to :perform
  end

  it "should break up the Excel spreadsheet" do
    @file  =File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls') 
    @file.stub(:original_filename => 'dechen_rangdrol_archives_database.xls')
    @file.stub(:content_type => 'application/vnd.ms-excel')
    @chattel = Cocupu::Spreadsheet.create(:attachment => @file)
    @job = DecomposeSpreadsheetJob.new(@chattel.id, JobLogItem.new)
    @job.enqueue #start the logger
    @job.perform
    sheets = Cocupu::Spreadsheet.find(@chattel.id).worksheets
    sheets.count.should == 1
    sheets.first.rows.count.should == 434
  end
  it "should break up the ODS spreadsheet" do
    @file = File.new(Rails.root + 'spec/fixtures/Stock Check 2.ods')
    @file.stub(:original_filename => 'Stock Check 2.ods')
    @file.stub(:content_type => 'application/vnd.oasis.opendocument.spreadsheet')
    @chattel = Cocupu::Spreadsheet.create(:attachment => @file)
    @job = DecomposeSpreadsheetJob.new(@chattel.id, JobLogItem.new)
    @job.enqueue #start the logger
    @job.perform
    sheets = Cocupu::Spreadsheet.find(@chattel.id).worksheets
    sheets.count.should == 4
    datasheet = sheets.select{|s| s.name == 'datasheet'}.first
    datasheet.order.should == 0
    datasheet.rows.count.should == 39 
    minerals = sheets.select{|s| s.name == 'calculation sheet _ minerals'}.first
    minerals.order.should == 1

    aluminum = minerals.rows.select{|r| r.row_number == 3}.first
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
