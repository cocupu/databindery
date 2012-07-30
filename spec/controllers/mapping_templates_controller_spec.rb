require 'spec_helper'

describe MappingTemplatesController do
  describe "create with a single model" do
    before do
      Model.count.should == 0  #Make sure the db is clean
      @ss = Worksheet.create!
    end
    describe "when not logged in" do
      it "should not create" do
        Worksheet.any_instance.should_receive(:reify).never
        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
        response.should redirect_to new_user_session_path
        flash[:alert].should == "You need to sign in or sign up before continuing."
      end
    end
    describe "when logged in" do
      before { sign_in FactoryGirl.create :login }
      it "should create" do
        Worksheet.any_instance.should_receive(:reify)

        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}
        assigns[:mapping_template].row_start.should == 2
        model = Model.find(assigns[:mapping_template].model_mappings.first[:model_id])
        Model.count.should == 1
        model.fields.should == {'file_name' => "File Name", 'title' => "Title"}
        model.name.should == 'Talk'
        model.label.should == "title"
        mapping = assigns[:mapping_template].model_mappings[0]
        mapping[:field_mappings].should == [ {"label"=>"File Name", "source"=>"A", 'field' => 'file_name'},
           {"label"=>"Title", "source"=>"C", 'field' => 'title'},
           {"label"=>"", "source"=>"D"}]

        response.should redirect_to(:action=>'show', :id=>assigns[:mapping_template].id)
      end
      it "should raise errors if no model name was supplied" do
        Worksheet.any_instance.should_receive(:reify).never

        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}
        assigns[:mapping_template].row_start.should == 2
        Model.count.should == 0
        response.should be_success
        flash[:alert].should == "Name can't be blank"
        assigns[:mapping_template].model_mappings[0][:field_mappings].should == 
          [ {"label"=>"File Name", "source"=>"A", 'field' => 'file_name'},
           {"label"=>"Title", "source"=>"C", 'field' => 'title'},
           {"label"=>"", "source"=>"D"}]
        assigns[:mapping_template].model_mappings[0][:label].should == 'C'
      end
    end
  end

  describe "show" do
    before do
      @template = MappingTemplate.new
      @template.attributes = {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}} 
      @template.save
      sign_in FactoryGirl.create :login 
    end
    it "should show" do
      get :show, :spreadsheet_id=>7, :id=>@template.id
      response.should be_success
      assigns[:mapping_template].should == @template
    end
  end

  describe 'new' do
    before do
      @one = FactoryGirl.create :worksheet
      sign_in FactoryGirl.create :login 
    end
    it "should be success" do
      get :new, :mapping_template=>{:worksheet_id => @one.id}
      assigns[:worksheet].should == @one
      assigns[:mapping_template].should_not be_nil
      assigns[:mapping_template].model_mappings.length.should == 1
      vals = @one.rows[0].values
      assigns[:mapping_template].model_mappings.first[:field_mappings].should == 
        [{:source =>"A", :label=>vals[0]}, 
          {:source => "B", :label=>vals[1]},
          {:source=>"C", :label=>vals[2]},
          {:source =>"D", :label=>vals[3]},
          {:source=>"E", :label=>vals[4]}]
      response.should be_success
    end
  end

end
