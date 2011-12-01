require 'spec_helper'

describe JobLogItemsController do
  describe "show" do
    before do
      @item = JobLogItem.create()
    end
    it "should return successfully" do
      get :show, :id=>@item.id
      response.should be_success
      assigns[:job_log_item].should == @item
    end
  end

end
