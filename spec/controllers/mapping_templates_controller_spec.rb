require 'spec_helper'

describe MappingTemplatesController do
  describe "create with a single model" do
    before do
      Model.delete_all
      Model.count.should == 0  #Make sure the db is clean
      @worksheet = FactoryGirl.create(:worksheet)
    end
    describe "when not logged in" do
      it "should not create" do
        pool = FactoryGirl.create(:pool)
        Worksheet.any_instance.should_receive(:reify).never
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>'bob', :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}, :pool_id=>pool
        response.should redirect_to new_user_session_path
        flash[:alert].should == "You need to sign in or sign up before continuing."
      end
    end
    describe "when logged in" do
      before do
        @identity = FactoryGirl.create :identity
        @pool = FactoryGirl.create(:pool, owner: @identity)
        sign_in @identity.login_credential
      end
      it "should create" do
        Worksheet.any_instance.should_receive(:reify).never
        original_model_count = Model.count 
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>@identity.short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
        assigns[:mapping_template].row_start.should == 2
        model = Model.find(assigns[:mapping_template].model_mappings.first[:model_id])
        Model.count.should == original_model_count+1
        model.fields.count.should == 2
        model.fields.where(code:"file_name").first.name.should == "File Name"
        model.fields.where(code:"title").first.name.should == "Title"
        model.name.should == 'Talk'
        model.label_field.should == model.fields.where(code:'title').first
        mapping = assigns[:mapping_template].model_mappings[0]
        mapping[:field_mappings].should == [ {"label"=>"File Name", "source"=>"A", 'field' => 'file_name'},
           {"label"=>"Title", "source"=>"C", 'field' => 'title'},
           {"label"=>"", "source"=>"D"}]

        response.should redirect_to( new_identity_pool_spawn_job_path(@identity, @pool, classic:true, worksheet_id:@worksheet.id, mapping_template_id:assigns[:mapping_template].id, skip_decompose:true) )
      end
      it "should raise errors if no model name was supplied" do
        Worksheet.any_instance.should_receive(:reify).never
        original_model_count = Model.count
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>@identity.short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
        assigns[:mapping_template].row_start.should == 2
        Model.count.should == original_model_count
        response.should be_success
        flash[:alert].should == "Name can't be blank"
        assigns[:mapping_template].model_mappings[0][:field_mappings].should == 
          [ {"label"=>"File Name", "source"=>"A", 'field' => 'file_name'},
           {"label"=>"Title", "source"=>"C", 'field' => 'title'},
           {"label"=>"", "source"=>"D"}]
        assigns[:mapping_template].model_mappings[0][:label].should == 'C'
      end
      it "should raise not_found errors when identity does not belong to the logged in user" do
        Worksheet.any_instance.should_receive(:reify).never
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>FactoryGirl.create(:identity).short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
        response.should be_not_found
      end
      it "should support simplified model and field mappings from json" do
        params = {:identity_id=>@identity.short_name, :pool_id=>@pool, :worksheet_id=>nil,
                  mapping_template: {
                    "row_start"=>2,
                    "model_mappings"=>[{
                        "name"=>"KTGR Archive Collection List Sample.xls Row",
                        "label" => 2,
                        "field_mappings"=>[{"source"=>0, "label"=>"Location"}, {"source"=>1, "label"=>"Submitted By"}, {"source"=>2, "label"=>"Collection Name"}]

                    }]
                  }
        }
        post :create, params
        generated_template = assigns[:mapping_template].model_mappings[0]
        generated_template[:field_mappings].should ==
            [{"source"=>"0", "label"=>"Location", "field"=>"location"},
             {"source"=>"1", "label"=>"Submitted By", "field"=>"submitted_by"},
             {"source"=>"2", "label"=>"Collection Name", "field"=>"collection_name"}]
        model = Model.find(assigns[:mapping_template].model_mappings.first[:model_id])
        model.label_field.should == model.fields.where(code:'collection_name').first
      end

    end
  end

  describe "show" do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create(:pool, owner: @identity)
      @template = MappingTemplate.new(owner: @pool.owner, pool: @pool)
      @template.attributes = {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}} 
      @template.save!
      sign_in @identity.login_credential
    end
    it "should show" do
      get :show, :spreadsheet_id=>7, :id=>@template.id, :pool_id=>@pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:mapping_template].should == @template
    end
  end

  describe 'new' do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create(:pool, owner: @identity)
      @one = FactoryGirl.create :worksheet
      sign_in @identity.login_credential
    end
    it "should be success" do
      get :new, :mapping_template=>{:worksheet_id => @one.id}, :pool_id=>@pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:pool].should == @pool
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
    end
    describe "when worksheet_id is not provided but node_id is provided" do
      it "should find the node and use its worksheet" do
        
        @node = Bindery::Spreadsheet.create(pool: FactoryGirl.create(:pool), model: Model.file_entity)
        @one.spreadsheet = @node
        @one.save
        
        get :new, :node_id=>@node.persistent_id, :pool_id=>@pool, identity_id: @identity.short_name
        response.should be_success
        assigns[:pool].should == @pool
        assigns[:worksheet].should == @one
        assigns[:mapping_template].should_not be_nil
        assigns[:mapping_template].model_mappings.length.should == 1
        vals = assigns[:worksheet].rows[0].values
        assigns[:mapping_template].model_mappings.first[:field_mappings].should == 
          [{:source =>"A", :label=>vals[0]}, 
            {:source => "B", :label=>vals[1]},
            {:source=>"C", :label=>vals[2]},
            {:source =>"D", :label=>vals[3]},
            {:source=>"E", :label=>vals[4]}]
      end
    end
  end

end
