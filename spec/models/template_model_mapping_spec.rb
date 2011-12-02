require 'spec_helper'

describe TemplateModelMapping do
  it "Should have name" do
    template = TemplateModelMapping.new
    template.name = "Truck"
    template.name.should == 'Truck'
  end

  describe "referenced_model" do
    before do
      @model = Model.create(:name=>'Truck')
    end
    it "should find referenced_model" do
      template = TemplateModelMapping.new(:name => "Truck")
      template.referenced_model.should == @model
    end
  end
end
