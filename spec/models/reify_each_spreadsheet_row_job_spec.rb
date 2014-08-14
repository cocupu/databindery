require 'spec_helper'

describe ReifyEachSpreadsheetRowJob do
  before do
    ## database should be clean
    @starting_node_count = Node.count
    @model = FactoryGirl.create(:model, fields_attributes: [{code: 'wheels', name: 'Wheels'}])
    @template = MappingTemplate.new(owner: FactoryGirl.create(:identity))
    @template.model_mappings = [{:model_id=>@model.id, :field_mappings=> [{:source=>"B", :label=>"Wheels", :field=>"wheels"}, {:source=>"A", :label=>''}]}]
    @template.save!
    @pool = FactoryGirl.create :pool
    # The source_node isn't actually used in the process, but each created Entity should declare it as the source
    @source_node = FactoryGirl.create(:spreadsheet, pool:@pool, model:Model.file_entity)
    @worksheet = FactoryGirl.create(:worksheet, spreadsheet:@source_node)
    @ss_row = SpreadsheetRow.create!(:values=>['one', 'two', 'three'], worksheet:@worksheet)
    @ticket = JobLogItem.new(:data=>{:id=>@ss_row.id, :template_id => @template.id, :pool_id => @pool.id})
  end
  it "should process" do
    job = ReifyEachSpreadsheetRowJob.new(@ticket)
    job.enqueue
    job.perform
    Node.count.should == @starting_node_count + 2
    # created = Node.all.select {|n| n != @source_node}.first
    created = Node.first
    created.model.should == @model
    created.data.should == {'wheels' => 'two'}
    created.spawned_from_datum.should == @ss_row
  end

end
