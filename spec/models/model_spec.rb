require 'spec_helper'

describe Model do
  it "should have many fields" do
    @model = Model.new()
    @model.m_fields << Field.new(:label=>"One")
    @model.m_fields << Field.new(:label=>"Two")
    @model.m_fields.first.label.should == "One"
  end
end
