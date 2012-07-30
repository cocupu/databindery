require 'spec_helper'

describe ReifyEachSpreadsheetRowJob do
  before do
    ## database should be clean
    Node.count.should == 0 
    @model = Model.create(:name=>'Truck', :fields=>{'wheels' => 'Wheels'})
    @template = MappingTemplate.new()
    @template.model_mappings = [{:model_id=>@model.id, :field_mappings=> [{:source=>"B", :label=>"Wheels", :field=>"wheels"}, {:source=>"A", :label=>''}]}]
    @template.save!
    @ss_row = SpreadsheetRow.create!(:values=>['one', 'two', 'three'])
    @pool = Pool.create!(:owner=>Identity.create!)
    @ticket = JobLogItem.new(:data=>{:id=>@ss_row.id, :template_id => @template.id, :pool_id => @pool.id})
  end
  it "should process" do
    job = ReifyEachSpreadsheetRowJob.new(@ticket)
    job.enqueue
    job.perform
    Node.count.should == 1
    created = Node.first
    created.model.should == @model
    created.data.should == {'wheels' => 'two'}
  end

end
