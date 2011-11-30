require 'spec_helper'

describe ProcessChain do
  describe "initialize" do
    it "Should be ready" do
      @process = ProcessChain.new
      @process.status.should == "READY"
    end
    it "should have many steps" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'])
      @process.steps.should == ['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow']
    end

    it "should have inputs" do
      @process = ProcessChain.new(:input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      @process.input.should == {:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}}
    end

  end

  describe "start" do
    it "should launch the first job" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'], :input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      DecomposeSpreadsheetJob.expects(:new).with({:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}}, nil)
      @process.start
      @process.status.should == 'PROCESSING'
      @process.current_step.should == 'DecomposeSpreadsheet'
    end
  end

  describe "Increment" do
    it "should increment step" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'], :input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      @process.current_step = 'DecomposeSpreadsheet'
      lambda {@process.increment_step!}.should raise_error "IllegalState: can't increment step unless status is 'PROCESSING'"
    end
    it "should increment step" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'], :input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      DecomposeSpreadsheetJob.expects(:new)
      @process.start
      @process.increment_step!
      @process.status.should == 'PROCESSING'
      @process.current_step.should  == 'ReifyEachSpreadsheetRow'
      
    end
    it "should finish the task" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'], :input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      #DecomposeSpreadsheetJob.expects(:new)
      @process.start
      @process.increment_step!
      @process.increment_step!
      @process.status.should == 'DONE'
      @process.current_step.should be_nil
      
    end
    it "should not allow increment after finish" do
      @process = ProcessChain.new(:steps=>['DecomposeSpreadsheet', 'ReifyEachSpreadsheetRow'], :input=>{:spreadsheet_id=>'999', :mapping=>{:col1=>'User#name'}})
      #DecomposeSpreadsheetJob.expects(:new)
      @process.start
      @process.increment_step!
      @process.increment_step!
      lambda {@process.increment_step!}.should raise_error "IllegalState: can't increment step unless status is 'PROCESSING'"
      @process.status.should == 'DONE'
      @process.current_step.should be_nil
      
    end
  end
end
