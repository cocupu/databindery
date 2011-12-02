require 'spec_helper'

describe ConcurrentJob do
  it "should have status" do
    job = ConcurrentJob.new()
    job.status.should == "READY"
  end

  it "should enqueue_jobs" do
    job = ConcurrentJob.new()
    mock_row1 = mock("row1")
    mock_row2 = mock("row2")
    mock_input = mock("input")
    j1 = mock('job1')
    j2 = mock('job2')
    ReifyEachSpreadsheetRowJob.expects(:new).with(mock_row1, mock_input, job.id).returns(j1)
    ReifyEachSpreadsheetRowJob.expects(:new).with(mock_row2, mock_input, job.id).returns(j2)
    Delayed::Job.expects(:enqueue).with(j1)
    Delayed::Job.expects(:enqueue).with(j2)
    job.enqueue_jobs(ReifyEachSpreadsheetRowJob, [mock_row1, mock_row2], mock_input)
    job.status.should == 'PROCESSING'
  end

  it "should set finished when all jobs done" do
    pending
  end
  it "should not enqueue header rows"
end
