require 'spec_helper'

describe FieldMapping do
  it "should have label" do
    fm = FieldMapping.new
    fm.label = "Net Weight"
    fm.label.should == "Net Weight"
  end
  it "should have source" do
    fm = FieldMapping.new
    fm.source = "F"
    fm.source.should == "F"
  end
end
