require 'spec_helper'

describe ModelInstance do
  it "should have a model" do
    model = Model.new
    instance = ModelInstance.new(:model=>model)
    instance.model.should == model
  end
  it "should not be valid unless it has a model" do
    instance = ModelInstance.new()
    instance.should_not be_valid
    instance.model = Model.new
    instance.should be_valid
  end
end
