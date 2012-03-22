require 'spec_helper'

describe JobLogItem do
  it "should have status" do
    @job_log_item = JobLogItem.create(:status =>'NEW')
    @job_log_item.status.should == 'NEW'
  end
  
  it "should have parents and children" do
    @conc = ConcurrentJob.create
    @child1 = JobLogItem.create
    @conc.children = [@child1, JobLogItem.create]
    @child1.parent.should == @conc
  end

  it "should alert parents when the status changes" do
    @conc = ConcurrentJob.create
    @child1 = JobLogItem.create(:parent=>@conc)

    @conc.expects(:member_finished)
    @child1.update_attribute(:status, 'FAILED')
    @child1.status.should == 'FAILED'
  end
  describe ".create" do
    subject {JobLogItem.create }
    its(:data) { should be_nil}
  end
end
