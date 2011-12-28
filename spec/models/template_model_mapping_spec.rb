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

  describe "filter properties" do
    before do
      @template = TemplateModelMapping.new(:name => "Truck")
    end
    it "should have source" do
      @template.filter_source = 'F'
      @template.filter_predicate = 'equal'
      @template.filter_constant = 'Ford'
    end
  end
end
