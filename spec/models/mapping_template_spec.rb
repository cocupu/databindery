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
end
