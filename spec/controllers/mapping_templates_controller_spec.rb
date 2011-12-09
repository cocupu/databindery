require 'spec_helper'

describe MappingTemplatesController do
  describe "create with a single model" do
    before do
      Model.count.should == 0  #Make sure the db is clean
      @ss = Worksheet.create!
    end
    it "should create" do
      Worksheet.any_instance.expects(:reify)

      post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
      assigns[:mapping_template].row_start.should == 2
      assigns[:mapping_template].models.first.name.should == 'Talk'
      assigns[:mapping_template].models.first.field_mappings.size.should == 2
      assigns[:mapping_template].models.first.field_mappings[0].label.should == 'File Name'
      assigns[:mapping_template].models.first.field_mappings[0].source.should == 'A'
      assigns[:mapping_template].models.first.field_mappings[1].label.should == 'Title'
      assigns[:mapping_template].models.first.field_mappings[1].source.should == 'C'
      Model.count.should == 1
      Model.first.m_fields.first.label.should == 'File Name'

      response.should redirect_to(:action=>'show', :id=>assigns[:mapping_template].id)
    end
    it "should raise errors if no model name was supplied" do
      Worksheet.any_instance.expects(:reify).never

      post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
      assigns[:mapping_template].row_start.should == 2
      assigns[:mapping_template].models.first.errors[:name].should == ["can't be blank"]
      Model.count.should == 0
      response.should be_success
      flash[:error].should == ["Name can't be blank"]
    end
  end

  describe "show" do
    before do
      @template = MappingTemplate.new
      @template.attributes = {"row_start"=>"2", :models=>{'0'=>{:name=>"Talk", :mapping=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}} 
      @template.save
    end
    it "should show" do
      get :show, :spreadsheet_id=>7, :id=>@template.id
      response.should be_success
      assigns[:mapping_template].should == @template
    end
  end

  describe 'new' do
    before do
      @spreadsheet = Cocupu::Spreadsheet.create!()
      @one = Worksheet.create(:spreadsheet=>@spreadsheet)
    end
    it "should be success" do
      get :new, :mapping_template=>{:worksheet_id => @one.id}
      assigns[:worksheet].should == @one
      assigns[:mapping_template].should_not be_nil
      assigns[:mapping_template].models.length.should == 1
      assigns[:mapping_template].models[0].field_mappings.length.should == 1
      response.should be_success
    end
  end

end
