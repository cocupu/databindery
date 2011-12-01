require 'spec_helper'

describe MappingTemplate do
  before do
    @template = MappingTemplate.new(:row_start=>3)
  end
  it "should have row_start" do
    @template.row_start.should == 3
  end
end
