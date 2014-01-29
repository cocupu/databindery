require 'spec_helper'

describe SpawnJobsController do
  describe "create with a single model" do
    before do
      Model.delete_all
      Model.count.should == 0  #Make sure the db is clean
      @node = FactoryGirl.create(:spreadsheet)
      @worksheet = FactoryGirl.create(:worksheet, spreadsheet:@node)
      @mapping_template = FactoryGirl.create(:mapping_template, {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}})
    end
    describe "when not logged in" do
      it "should not create" do
        pool = FactoryGirl.create(:pool)
        SpawnJob.should_receive(:new).never
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>'bob', :mapping_template_id=>@mapping_template.id, :pool_id=>pool
        response.should redirect_to new_user_session_path
        flash[:alert].should == "You need to sign in or sign up before continuing."
      end
    end
    describe "when logged in" do
      before do
        @identity = FactoryGirl.create :identity
        @pool = FactoryGirl.create(:pool, owner: @identity)        
        sign_in @identity.login_credential
        @mapping_template = FactoryGirl.create(:mapping_template, {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}})
        @file  =File.new(Rails.root + 'spec/fixtures/KTGR Audio Collection Sample.xlsx')
        @node.stub(:s3_obj).and_return(@file)
        @node.file_name = 'KTGR Audio Collection Sample.xlsx'
        @node.mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        Bindery::Spreadsheet.stub(:find_by_identifier).and_return(@node)
      end
      it "should create" do
        Bindery::ReifyRowJob.stub(:create).and_return("jobId")
        post :create, :source_node_id=>@node.id, :identity_id=>@identity.short_name, :mapping_template_id=>@mapping_template.id, :pool_id=>@pool
        assigns[:mapping_template].should == @mapping_template
        assigns[:spawn_job].pool.should == @pool
        assigns[:spawn_job].mapping_template.should == @mapping_template
        assigns[:spawn_job].node.should == @node
        assigns[:spawn_job].reification_job_ids.count.should == 18
        flash[:notice].should == "Spawning 18 entities from #{@node.title}. Refresh this page to see them appear in your search results as they spawn."
        response.should redirect_to(identity_pool_search_path(@identity, @pool))
      end
      it "should raise not_found errors when identity does not belong to the logged in user" do
        SpawnJob.should_receive(:new).never
        post :create, :worksheet_id=>@worksheet.id, :identity_id=>FactoryGirl.create(:identity).short_name, :mapping_template_id=>@mapping_template.id, :pool_id=>@pool
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
      pending
      get :show, :spreadsheet_id=>7, :id=>@template.id, :pool_id=>@pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:mapping_template].should == @template
    end
  end

  describe 'new' do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create(:pool, owner: @identity)
      @node = FactoryGirl.create(:spreadsheet, pool:@pool, model:Model.file_entity)
      @template = MappingTemplate.new(owner: @pool.owner, pool: @pool)
      @template.attributes = {"row_start"=>"2", :model_mappings_attributes=>{'0'=>{:name=>"Talk", :field_mappings_attributes=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}} 
      @template.save!
      @one = FactoryGirl.create :worksheet
      sign_in @identity.login_credential
    end
    it "should be success" do
      get :new, :mapping_template_id=>@template.id, :worksheet_id=>@one.id, :pool_id=>@pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:pool].should == @pool
      assigns[:worksheet].should == @one
      assigns[:mapping_template].should == @template
    end
    it "should be success when template not specified" do
      get :new, :worksheet_id=>@one.id, :pool_id=>@pool, identity_id: @identity.short_name
      response.should be_success
      assigns[:pool].should == @pool
      assigns[:worksheet].should == @one
      assigns[:mapping_template].should == nil
    end
    describe "when worksheet_id is not provided but source_node_id is provided" do
      it "if skip_decompose is set, should just grab worksheet from node" do
        @one.spreadsheet = @node
        @one.save
        @job = DecomposeSpreadsheetJob.new(@node.id, JobLogItem.new)
        DecomposeSpreadsheetJob.stub(:new).and_return(@job)
        @job.should_receive(:enqueue).never
        get :new, :skip_decompose=>"true", :source_node_id=>@node.id, :pool_id=>@pool, identity_id: @identity.short_name
        response.should be_success
        assigns[:worksheet].should == @one
        assigns[:job].should == @job
      end
      it "should trigger decomposition of the nodes current worksheet" do
        # setup for decomposing spreadsheet (stubs s3 connection).  See decompose_spreadsheet_job_spec.rb for more of this
          @file  =File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls') 
          @node = Bindery::Spreadsheet.create(pool: FactoryGirl.create(:pool), model: Model.file_entity)
          # S3Object.read behaves like File.read, so returning a File as stub for the S3 Object
          @node.stub(:s3_obj).and_return(@file)
          @node.file_name = 'dechen_rangdrol_archives_database.xls'
          @node.mime_type = 'application/vnd.ms-excel'
          Bindery::Spreadsheet.stub(:find_by_persistent_id).with(@node.persistent_id).and_return(@node)
        # /setup for decomposing spreadsheet
        @node.worksheets.should be_empty
        get :new, :source_node_id=>@node.persistent_id, :pool_id=>@pool, identity_id: @identity.short_name
        response.should be_success
        assigns[:pool].should == @pool
        assigns[:worksheet].should == @node.worksheets.first
        
        # force the job to run & check its output
        assigns[:job].perform
        processed_sheet = assigns[:source_node].worksheets.first
        processed_sheet.rows.count.should == 434
      end
    end
  end

end
