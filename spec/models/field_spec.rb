require 'spec_helper'

describe Field do
  it "should have a label" do
    @field = Field.new(:label=>"Net Weight")
    @field.label.should == "Net Weight"
  end
end
