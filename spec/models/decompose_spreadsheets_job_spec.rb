require 'spec_helper'


describe DecomposeSpreadsheetJob do
  it "should have perform" do
    
    @job = DecomposeSpreadsheetJob.new(1234, nil)
    @job.node_id.should == 1234
    @job.should respond_to :perform
  end

  it "should break up the Excel spreadsheet" do
    @file  =File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls') 
    @node = Bindery::Spreadsheet.create(pool: FactoryGirl.create(:pool), model: Model.file_entity)
    # This requires S3 connection, so skipping.
    # @node.attach_file('dechen_rangdrol_archives_database.xls', @file.read)
    # @node.save!

    # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
    @node.stub(:s3_obj).and_return(@file)
    @node.file_name = 'dechen_rangdrol_archives_database.xls'
    @node.mime_type = 'application/vnd.ms-excel'
    Bindery::Spreadsheet.stub(:find).with(@node.id).and_return(@node)
    
    @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
    @job.enqueue #start the logger
    @job.perform
    Bindery::Spreadsheet.unstub(:find)
    sheets = Bindery::Spreadsheet.find(@node.id).worksheets
    sheets.count.should == 1
    sheets.first.rows.count.should == 434
  end
  it "should break up the ODS spreadsheet" do
    @file = File.new(Rails.root + 'spec/fixtures/Stock Check 2.ods')
    @node = Bindery::Spreadsheet.create(pool: FactoryGirl.create(:pool), model: Model.file_entity)

    # This requires S3 connection, so skipping.
    # @node.attach_file('Stock Check 2.ods', @file.read)
    # @node.save!

    # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
    @node.stub(:s3_obj).and_return(@file)
    @node.file_name = 'Stock Check 2.ods'
    @node.mime_type = 'application/vnd.oasis.opendocument.spreadsheet'
    Bindery::Spreadsheet.stub(:find).with(@node.id).and_return(@node)    
    @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
    @job.enqueue #start the logger
    @job.perform
    Bindery::Spreadsheet.unstub(:find)
    sheets = Bindery::Spreadsheet.find(@node.id).worksheets
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
