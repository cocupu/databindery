require 'spec_helper'

describe Model do
  it "should have many fields" do
    @model = Model.new()
    @model.fields = {'one' => 'One'}
    @model.fields['two'] = 'Two'
    @model.fields['one'].should == "One"
  end
end
