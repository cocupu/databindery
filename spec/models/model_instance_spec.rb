require 'spec_helper'

describe ModelInstance do
  it "should have a model" do
    model = Model.create
    instance = ModelInstance.new(:model=>model)
    instance.model.should == model
  end
  it "should not be valid unless it has a model" do
    instance = ModelInstance.new()
    instance.should_not be_valid
    instance.model = Model.create
    instance.should be_valid
  end

  describe "with properties" do
    before do
      @model = Model.create(:name=>"Mods and Rockers")
      f1 = Field.new(:label=>'Field one')
      @model.m_fields = [f1]
      @model.save

      @instance = ModelInstance.new(:model=>@model)
      @instance.save
      @instance.properties = [Property.new(:value=>"good", :field=>f1) ]
    end

    it "should get fields by label" do
      @instance.get('Field one').should == 'good'
      
    end

    it "should produce a solr document" do
      @instance.to_solr(@model.m_fields).should == {'id'=>@instance.id, 'model' =>'Mods and Rockers', "field_one_s"=>"good"}
    end
  end
end
