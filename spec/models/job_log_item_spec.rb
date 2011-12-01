require 'spec_helper'

describe JobLogItem do
  it "should have status" do
    @job_log_item = JobLogItem.create(:status =>'NEW')
    @job_log_item.status.should == 'NEW'
  end
end
