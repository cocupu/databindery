require 'spec_helper'

describe ReifyEachSpreadsheetRowJob do
  before do
    ## database should be clean
    Node.count.should == 0 
    @model = Model.create!(:name=>'Truck', owner: FactoryGirl.create(:identity), :fields=>[{code: 'wheels', name: 'Wheels'}])
    @template = MappingTemplate.new(owner: FactoryGirl.create(:identity))
    @template.model_mappings = [{:model_id=>@model.id, :field_mappings=> [{:source=>"B", :label=>"Wheels", :field=>"wheels"}, {:source=>"A", :label=>''}]}]
    @template.save!
    @ss_row = SpreadsheetRow.create!(:values=>['one', 'two', 'three'])
    @pool = FactoryGirl.create :pool
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
