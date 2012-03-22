require 'spec_helper'

describe ConcurrentJob do
  it "should have status" do
    job = ConcurrentJob.new()
    job.status.should == "READY"
  end


  it "should enqueue_collection" do
    job = ConcurrentJob.new()
    mock_row1 = mock("row1")
    mock_row2 = mock("row2")
    mock_input = mock("input")
    # j1 = mock('job1')
    # j2 = mock('job2')
    # ReifyEachSpreadsheetRowJob.expects(:new).returns(j1)#.with(mock_row1, mock_input, job.id, log )
    # ReifyEachSpreadsheetRowJob.expects(:new).returns(j2)#.with(mock_row2, mock_input, job.id, log )

    JobLogItem.expects(:create).returns(mock('log_item', :key=>'abc123'))
    JobLogItem.expects(:create).returns(mock('log_item', :key=>'def456'))
    mock_queue = mock('queue')
    Carrot.expects(:queue).with('reify_each_spreadsheet_row_job').returns(mock_queue).twice
    mock_queue.expects(:publish).with('abc123')
    mock_queue.expects(:publish).with('def456')
    job.enqueue_collection(ReifyEachSpreadsheetRowJob, [mock_row1, mock_row2], mock_input)
    job.status.should == 'PROCESSING'
  end
  describe "find_children_with_status" do
    before do
      @conc = ConcurrentJob.create(:status=>'READY')
      @child1 = JobLogItem.create(:parent=>@conc, :status=>'READY')
    end
    it "should find child" do
      @conc.find_children_with_status(['READY']).should == [@child1.key]
    end
  end

  describe "member_finished" do
    before do
      @conc = ConcurrentJob.create(:status=>'READY')
      @child1 = JobLogItem.create(:parent=>@conc, :status=>'READY')
    end
    it "should set finished when all jobs done" do
      @child1.update_attribute(:status, 'FAILED')
      @conc.status.should == 'FAILED'
    end
    it "should set finished when all jobs done" do
      @child1.update_attribute(:status, 'SUCCESS')
      @conc.status.should == 'SUCCESS'
    end
    it "should not set finished if any job is READY" do
      @child2 = JobLogItem.create(:parent=>@conc, :status=>'READY')
      @child1.update_attribute(:status, 'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
    it "should not set finished if any job is ENQUEUE" do
      @child2 = JobLogItem.create(:parent=>@conc, :status=>'ENQUEUE')
      @child1.update_attribute(:status, 'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
    it "should not set finished if any job is PROCESSING" do
      @child2 = JobLogItem.create(:parent=>@conc, :status=>'PROCESSING')
      @child1.update_attribute(:status, 'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
  end
  it "should not enqueue header rows"
end
