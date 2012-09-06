require 'spec_helper'

describe DrivesController do

  describe "index" do
    describe "when not signed in" do
      it "should redirect" do
        get :index
        response.should redirect_to new_user_session_path
      end
    end
    describe "when signed in" do
      before do
        @user = FactoryGirl.create :login
        sign_in @user
      end
      describe "and not authorized" do
        it "should redirect to get an oauth token" do
          get :index
          response.should redirect_to "https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&client_id=840123515072-bi3cnnt361ek7tnqfgbc05npt4h096k8.apps.googleusercontent.com&redirect_uri=http://bindery.cocupu.com:3001/drives&response_type=code&scope=https://www.googleapis.com/auth/drive.readonly%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/userinfo.profile&user_id="
        end
        it "should redirect to get an oauth token" do
          get :index, :format=>:json
          response.code.should == '401'
          json = JSON.parse response.body
          json.should == {'redirect'=>"https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&client_id=840123515072-bi3cnnt361ek7tnqfgbc05npt4h096k8.apps.googleusercontent.com&redirect_uri=http://bindery.cocupu.com:3001/drives&response_type=code&scope=https://www.googleapis.com/auth/drive.readonly%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/userinfo.profile&user_id="}
        end
      end
      describe "with code" do
        before do
        end
        it "should authorize code" do
          controller.should_receive(:authorize_code).with('1235')
          get :index, :code=>'1235'
          response.should be_redirect
        end
      end
      describe "and authorized" do
        before do
          controller.should_receive(:authorized?).and_return(true)
          @mock_client = stub("Api client")
          @mock_client.stub(:authorization).and_return(stub("authorization", :update_token! => true, :refresh_token=>false, :access_token=>'131', :expires_in => '9999', :issued_at=>'34234'))
          controller.stub(:api_client).and_return(@mock_client)
        end
        it "should list files" do
          get :index
          response.should redirect_to models_path(:anchor=>'drive')
        end
        describe "Requesting json" do
          before do
            perm = stub("userPermission", :id=>"me")
            @files = [stub('file1', :id=>'12303230', :mime_type=>'text/html', :userPermission=>perm, :modifiedDate=>Time.parse("2011-08-23T21:28:10.800Z"), :title=>'Title one'), stub('file2', :mime_type=>'application/pdf', :id=>'230920398209', :userPermission=>perm, :parents=>[{:id=>'file1'}], :modifiedDate=>Time.parse("2011-08-23T21:28:10.800Z"), :title=>'Title two'), stub('folder', :mime_type=>'application/vnd.google-apps.folder' , :id=>'230920398200', :userPermission=>perm, :parents=>[{:id=>'file1'}], :modifiedDate=>Time.parse("2011-08-23T21:28:10.800Z"), :title=>'Title three')]
            @mock_client.should_receive(:execute!).with(:api_method => kind_of(Google::APIClient::Method)).and_return(stub("result", :data => stub("data", :items=>@files)))
          end
          it "should list files for json" do
            get :index, :format=>:json
            response.should be_success
            # it returns a list of files, see: https://developers.google.com/drive/v2/reference/files
            json = JSON.parse(response.body)
            json.should == [
                {'title' => 'Title one', 'id'=>'12303230', 'type'=>'file', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => [], "mime_type"=>"text/html"}, 
                {'title' => 'Title two', 'id'=>'230920398209', 'type'=>'file', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => [], "mime_type"=>"application/pdf"},
                {'title' => 'Title three', 'id'=>'230920398200', 'type'=>'folder', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => nil , "mime_type"=>"application/vnd.google-apps.folder"} ]
          end
        end
      end
    end
  end

  describe "spawn" do
    before do
      @user = FactoryGirl.create :login
      sign_in @user
    end
    it "should be successfull" do
      @mock_client = stub("Api client")
      @mock_client.stub(:authorization).and_return(stub("authorization", :update_token! => true, :refresh_token=>false, :access_token=>'131', :expires_in => '9999', :issued_at=>'34234'))
      @mock_client.should_receive(:execute!).with(:api_method => kind_of(Google::APIClient::Method),:parameters=>{"fileId"=>"12312415201"}).and_return(stub("result", :data => stub("data", :mime_type=>'text/html', :title=>'hey.xls', :downloadUrl=>'theRemoteFile')))
      @mock_client.should_receive(:execute).with(:uri=>"theRemoteFile").and_return(stub("result", :data => stub("data", :mime_type=>'text/html', :title=>'hey.xls'), :body=>"resulting content"))
      controller.stub(:api_client).and_return(@mock_client)
      mock_queue = mock('queue')
      Carrot.should_receive(:queue).with('decompose_spreadsheet').and_return(mock_queue)
      mock_log = stub("log", :id=>'6HceCIKd3ucLNco9583DVnmGW5E')
      JobLogItem.should_receive(:create).and_return(mock_log)
      mock_queue.should_receive(:publish).with('6HceCIKd3ucLNco9583DVnmGW5E')

      get :spawn, :id => '12312415201'
      assigns[:chattel].attachment.should_not be_nil
      response.should redirect_to(describe_chattel_path(assigns[:chattel], :log=>assigns[:log].id))
    end
  end

end
