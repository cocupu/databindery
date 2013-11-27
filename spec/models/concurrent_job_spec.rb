require 'spec_helper'

describe ConcurrentJob do
  it "should have status" do
    job = ConcurrentJob.new()
    job.status.should == "READY"
  end


  it "should enqueue_collection" do
    job = ConcurrentJob.new()
    mock_row1 = double("row1", :id=>123)
    mock_row2 = double("row2", :id=>235)

    log1 =JobLogItem.create
    log2 =JobLogItem.create

    JobLogItem.should_receive(:new).and_return(log1)
    JobLogItem.should_receive(:new).and_return(log2)
    mock_queue = double('queue')
    Carrot.should_receive(:queue).twice.with('reify_each_spreadsheet_row_job').and_return(mock_queue)
    mock_queue.should_receive(:publish).with(log1.id)
    mock_queue.should_receive(:publish).with(log2.id)
    job.enqueue_collection(ReifyEachSpreadsheetRowJob, [mock_row1, mock_row2], {:template_id => 7, :pool_id=>5})
    job.status.should == 'PROCESSING'
  end
  describe "count_children_with_status" do
    before do
      @conc = ConcurrentJob.create(:status=>'READY')
      @child1 = JobLogItem.new(:status=>'READY')
      @child1.parent = @conc
      @child1.save!
    end
    it "should find child" do
      @conc.count_children_with_status(['READY']).should == 1
    end
  end

  describe "member_finished" do
    before do
      @conc = ConcurrentJob.create(:status=>'READY')
      @child1 = JobLogItem.new(:status=>'READY')
      @child1.parent = @conc
      @child1.save!
    end
    it "should set finished when all jobs done" do
      @child1.update_attributes(:status => 'FAILED')
      @conc.status.should == 'FAILED'
    end
    it "should set finished when all jobs done" do
      @child1.update_attributes(:status => 'SUCCESS')
      @conc.status.should == 'SUCCESS'
    end
    it "should not set finished if any job is READY" do
      @child2 = JobLogItem.new(:status=>'READY')
      @child2.parent = @conc
      @child2.save!
      @child1.update_attributes(:status =>'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
    it "should not set finished if any job is ENQUEUE" do
      @child2 = JobLogItem.new(:status=>'ENQUEUE')
      @child2.parent = @conc
      @child2.save!
      @child1.update_attributes(:status => 'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
    it "should not set finished if any job is PROCESSING" do
      @child2 = JobLogItem.new(:status=>'PROCESSING')
      @child2.parent = @conc
      @child2.save!
      @child1.update_attributes(:status => 'SUCCESS')
      @conc.status.should == 'PROCESSING'
    end
  end
end
