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
            json.should == [{'title' => 'Title one', 'type'=>'file', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => []}, {'title' => 'Title two', 'type'=>'file', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => []}, {'title' => 'Title three', 'type'=>'folder', 'owner' => 'me', 'date' => '23 Aug 21:28', 'bindings' => nil } ]
          end
        end
      end
    end
  end

end
