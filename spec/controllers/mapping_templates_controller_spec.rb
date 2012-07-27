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
        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
        response.should redirect_to new_user_session_path
        flash[:alert].should == "You need to sign in or sign up before continuing."
      end
    end
    describe "when logged in" do
      before { sign_in FactoryGirl.create :login }
      it "should create" do
        Worksheet.any_instance.should_receive(:reify)

        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
        assigns[:mapping_template].row_start.should == 2
        model = Model.find(assigns[:mapping_template].models.keys.first)
        Model.count.should == 1
        model.fields.should == {'file_name' => "File Name", 'title' => "Title"}
        model.name.should == 'Talk'
        mapping = assigns[:mapping_template].models[model.id]
        mapping[:field_mappings].should == {'A' =>'file_name', 'C'=>'title'}

        response.should redirect_to(:action=>'show', :id=>assigns[:mapping_template].id)
      end
      it "should raise errors if no model name was supplied" do
        Worksheet.any_instance.should_receive(:reify).never

        post :create, :worksheet_id=>@ss.id, :mapping_template=>{"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}
        assigns[:mapping_template].row_start.should == 2
        Model.count.should == 0
        response.should be_success
        flash[:alert].should == "Name can't be blank"
        assigns[:mapping_template].models[''][:field_mappings].should == {"A" => "File Name", "C"=>"Title", "D"=>''}
      end
    end
  end

  describe "show" do
    before do
      @template = MappingTemplate.new
      @template.attributes = {"row_start"=>"2", :models_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}} 
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
      assigns[:mapping_template].models.length.should == 1
      vals = @one.rows[0].values
      assigns[:mapping_template].models[''][:field_mappings].should == {"A"=>vals[0], "B"=>vals[1], "C"=>vals[2], "D"=>vals[3], "E"=>vals[4]}
      response.should be_success
    end
  end

end
