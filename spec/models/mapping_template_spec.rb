require 'spec_helper'

describe MappingTemplate do
  before do
    @template = MappingTemplate.new(:row_start=>3)
  end
  it "should have row_start" do
    @template.row_start.should == 3
  end

  it "should belong to an identity" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end

  describe "model_mappings" do
    before do
      @template.owner = FactoryGirl.create :identity
      @model = Model.create(:name=>'Truck', :fields=>{'avail_colors' => {:name=>"Colors"}})
    end
    it "should serialize and deserialize the mapping" do
      @template.model_mappings = [ 
         {:model_id => @model.id,
          :filter_source => 'F',
          :filter_predicate => 'equal',
          :filter_constant => 'Ford',
          :field_mappings=> {'C' => 'avail_colors' }}]
      @template.save!
      @template.reload
      @template.model_mappings[0][:field_mappings]['C'].should == 'avail_colors'
      @template.model_mappings[0][:model_id].should == @model.id

    end
  end

  describe "attributes=" do
    before do
      Model.count.should == 0
      @template.owner = FactoryGirl.create :identity
      @template.attributes = {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
    end
    it "should create the model and serialize the mapping" do
      Model.count.should == 1
      model = Model.first
      model.name.should == 'Talk'
      model.label.should == 'title'
      model.fields.should == [{:code=>"file_name", :name=>"File Name"}, {:code=>"title", :name=>"Title"}]

      @template.row_start.should == 2

      @template.model_mappings[0][:field_mappings][1][:label].should == 'Title'
      @template.model_mappings[0][:field_mappings][1][:field].should == 'title'
      @template.model_mappings[0][:name].should == 'Talk'
      @template.model_mappings[0][:label].should == 'C'
    end
  end

  describe "file_type" do
    it "should have a file_type" do
      subject.file_type= "foo"
      subject.file_type.should == "foo"
    end
  end
end
