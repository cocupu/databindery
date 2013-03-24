require 'spec_helper'

describe MappingTemplatesController do
  describe "create with a single model" do
    before do
      Model.delete_all
      Model.count.should == 0  #Make sure the db is clean
      @ss = Worksheet.create!
    end
    describe "when not logged in" do
      it "should not create" do
        pool = FactoryGirl.create(:pool)
        Worksheet.any_instance.should_receive(:reify).never
        post :create, :worksheet_id=>@ss.id, :identity_id=>'bob', :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}, :pool_id=>pool
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
        Worksheet.any_instance.should_receive(:reify)

        post :create, :worksheet_id=>@ss.id, :identity_id=>@identity.short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
        assigns[:mapping_template].row_start.should == 2
        model = Model.find(assigns[:mapping_template].model_mappings.first[:model_id])
        Model.count.should == 1
        model.fields.should == [{"code"=>"file_name", "name"=>"File Name"},
             {"code"=>"title", "name"=>"Title"}]
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

        post :create, :worksheet_id=>@ss.id, :identity_id=>@identity.short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
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
      it "should raise not_found errors when identity does not belong to the logged in user" do
        Worksheet.any_instance.should_receive(:reify).never

        post :create, :worksheet_id=>@ss.id, :identity_id=>FactoryGirl.create(:identity).short_name, :mapping_template=>{"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"", :label=>'C', :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>"D"}}}}}, :pool_id=>@pool
        response.should be_not_found
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
      it "should generate the worksheet from node then use that" do
        # setup for decomposing spreadsheet (stubs s3 connection).  See decompose_spreadsheet_job_spec.rb for more of this
          @file  =File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls') 
          @node = Bindery::Spreadsheet.create(pool: FactoryGirl.create(:pool), model: Model.file_entity)
          # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
          @node.stub(:s3_obj).and_return(@file)
          @node.file_name = 'dechen_rangdrol_archives_database.xls'
          @node.mime_type = 'application/vnd.ms-excel'
          Bindery::Spreadsheet.stub(:find_by_persistent_id).with(@node.persistent_id).and_return(@node)
        # /setup for decomposing spreadsheet
        
        get :new, :node_id=>@node.persistent_id, :pool_id=>@pool, identity_id: @identity.short_name
        response.should be_success
        assigns[:pool].should == @pool
        assigns[:job].node_id.should == @node.persistent_id.to_s        
        assigns[:worksheet].should == @node.worksheets.last
        assigns[:worksheet].rows.count.should == 434
        assigns[:mapping_template].should_not be_nil
        assigns[:mapping_template].model_mappings.length.should == 1
        vals = assigns[:worksheet].rows[0].values
        assigns[:mapping_template].model_mappings.first[:field_mappings].should == 
          [{:source =>"A", :label=>vals[0]}, 
            {:source => "B", :label=>vals[1]},
            {:source=>"C", :label=>vals[2]},
            {:source =>"D", :label=>vals[3]},
            {:source=>"E", :label=>vals[4]},
            {:source => "F", :label=>vals[5]},
            {:source=>"G", :label=>vals[6]},
            {:source =>"H", :label=>vals[7]},
            {:source=>"I", :label=>vals[8]},
            {:source => "J", :label=>vals[9]},
            {:source=>"K", :label=>vals[10]},
            {:source =>"L", :label=>vals[11]},
            {:source=>"M", :label=>vals[12]}]
      end
    end
  end

end
