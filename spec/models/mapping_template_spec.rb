require 'spec_helper'

describe MappingTemplate do
  before do
    @template = MappingTemplate.new(:row_start=>3)
  end
  it "should have row_start" do
    @template.row_start.should == 3
  end


  describe "models" do
    before do
      @model = Model.create(:name=>'Truck', :fields=>{'avail_colors' => "Colors"})
    end
    it "should serialize and deserialize the mapping" do
      @template.models = {@model.id => 
         {:filter_source => 'F',
          :filter_predicate => 'equal',
          :filter_constant => 'Ford',
          :field_mappings=> {'C' => 'avail_colors' }}}
      @template.save!
      @template.reload
      @template.models[@model.id][:field_mappings]['C'].should == 'avail_colors'

    end
  end

  describe "attributes=" do
    before do
      Model.count.should == 0
      @template.attributes = {"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
    end
    it "should create the model and serialize the mapping" do
      Model.count.should == 1
      model = Model.first
      model.name.should == 'Talk'
      model.fields.should == {'file_name' => 'File Name', 'title'=>'Title'}

      @template.models[model.id][:field_mappings]['C'].should == 'title'
    end
  end

  describe "file_type" do
    it "should have a file_type" do
      subject.file_type= "foo"
      subject.file_type.should == "foo"
    end
  end
end
