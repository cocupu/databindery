require 'spec_helper'

describe ReifyEachSpreadsheetRowJob do
  before do
    ModelInstance.list.count.should == 0 ## database should be clean
    @field = Field.new(:label=>'Wheels')
    @model = Model.create(:name=>'Truck', :m_fields=>[@field])
  end
  it "should process" do
    template = MappingTemplate.new()
    template.models << TemplateModelMapping.new(:name=>'Truck', :field_mappings=>[FieldMapping.new(:label=>"Wheels", :source=>'B')])
    job = ReifyEachSpreadsheetRowJob.new(SpreadsheetRow.new(:values=>['one', 'two', 'three'].map{|v| SpreadsheetRow::Value.new(:value=>v)}), {:template=>template}, mock("parent_id"), JobLogItem.new)
    job.enqueue(job)
    job.perform
    ModelInstance.list.count.should == 1
    created = ModelInstance.list.first
    created.model.should == @model
    created.properties.first.value.should == 'two'
    created.properties.first.field.should == @field 
  end

end
