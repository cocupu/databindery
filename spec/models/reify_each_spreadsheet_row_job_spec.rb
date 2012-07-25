require 'spec_helper'

describe ReifyEachSpreadsheetRowJob do
  before do
    ## database should be clean
    Node.count.should == 0 
    #@field = Field.new(:label=>'Wheels')
    @model = Model.create(:name=>'Truck', :fields=>{'wheels' => 'Wheels'})
  end
  it "should process" do
    template = MappingTemplate.new()
    template.models = {@model.id => {:field_mappings=> {'B' => 'wheels'}}}

    job = ReifyEachSpreadsheetRowJob.new(SpreadsheetRow.new(:values=>['one', 'two', 'three']), template, JobLogItem.new)
    job.enqueue
    job.perform
    Node.count.should == 1
    created = Node.first
    created.model.should == @model
puts "data #{created.data}"
    created.data['wheels'].should == 'two'
  end

end
