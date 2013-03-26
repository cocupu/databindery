require 'spec_helper'


describe DecomposeSpreadsheetJob do
  before do
    @pool = FactoryGirl.create :pool
    @node = Bindery::Spreadsheet.create(pool: @pool, model: Model.file_entity)
  end
  
  it "should have perform" do
    @job = DecomposeSpreadsheetJob.new(@node.id, nil)
    @job.node_id.should == @node.id
    @job.node.should == @node
    @job.should respond_to :perform
  end
  
  it "should accept Node persistent_ids" do
    @job = DecomposeSpreadsheetJob.new(@node.persistent_id, JobLogItem.new)
    Bindery::Spreadsheet.should_receive(:find_by_persistent_id).with(@node.persistent_id).and_return(@node)
    @job.node.should == @node
  end
  it "should accept Node ids" do
    @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
    Bindery::Spreadsheet.should_receive(:find).with(@node.id).and_return(@node)
    @job.node.should == @node
  end

  it "should break up the Excel spreadsheet" do
    @file  =File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls') 
    # This requires S3 connection, so skipping.
    # @node.attach_file('dechen_rangdrol_archives_database.xls', @file.read)
    # @node.save!

    # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
    @node.stub(:s3_obj).and_return(@file)
    @node.file_name = 'dechen_rangdrol_archives_database.xls'
    @node.mime_type = 'application/vnd.ms-excel'
    @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
    # Bindery::Spreadsheet.stub(:find).with(@node.id).and_return(@node)
    @job.node = @node
    @job.enqueue #start the logger
    @job.perform
    # Bindery::Spreadsheet.unstub(:find)
    sheets = Bindery::Spreadsheet.find(@node.id).worksheets
    sheets.count.should == 1
    sheets.first.rows.count.should == 434
  end
  it "should break up the ODS spreadsheet" do
    @file = File.new(Rails.root + 'spec/fixtures/Stock Check 2.ods')

    # This requires S3 connection, so skipping.
    # @node.attach_file('Stock Check 2.ods', @file.read)
    # @node.save!

    # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
    @node.stub(:s3_obj).and_return(@file)
    @node.file_name = 'Stock Check 2.ods'
    @node.mime_type = 'application/vnd.oasis.opendocument.spreadsheet'
    Bindery::Spreadsheet.should_receive(:find_by_identifier).with(@node.id).and_return(@node) 
    @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
    @job.enqueue #start the logger
    @job.perform
    # Bindery::Spreadsheet.unstub(:find)
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
  describe "ingest_worksheet" do
    it "should skip empty sheets within a spreadsheet" do
      @node.mime_type = 'application/vnd.oasis.opendocument.spreadsheet'
      type = Bindery::Spreadsheet.detect_type(@node)
      spreadsheet = type.new(File.expand_path(Rails.root + 'spec/fixtures/Texts.ods'))
      spreadsheet.sheets.each_with_index do |worksheet, index|
        subject.ingest_worksheet(spreadsheet, worksheet, @node, index)
      end
      node = Bindery::Spreadsheet.find(@node.id)
      node.worksheets.count.should == 1
    end
  end
end
