require 'spec_helper'

describe JobLogItem do
  it "should have status, data and name" do
    @job_log_item = JobLogItem.create(:status =>'NEW', :data=>'7', :name=>DecomposeSpreadsheetJob.to_s)
    @job_log_item.status.should == 'NEW'
    @job_log_item.data.should == '7'
    @job_log_item.name.should == 'DecomposeSpreadsheetJob'
  end
  
  it "should have parents and children" do
    @conc = ConcurrentJob.create
    @child1 = JobLogItem.create
    @conc.children = [@child1, JobLogItem.create]
    @child1.parent.should == @conc
  end

  it "should alert parents when the status changes" do
    @conc = ConcurrentJob.create
    @child1 = JobLogItem.new
    @child1.parent=@conc
    @child1.save!

    @conc.should_receive(:member_finished)
    @child1.update_attributes(:status => 'FAILED')
    @child1.status.should == 'FAILED'
  end

  it "should have data" do
    
  end
  describe ".create" do
    subject {JobLogItem.create }
    its(:data) { should be_nil}
  end
end
