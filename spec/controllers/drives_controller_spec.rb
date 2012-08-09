require 'spec_helper'

describe DrivesController do

  describe "index" do
    describe "when not signed in" do
      it "should list files" do
        get :index
        response.should redirect_to new_user_session_path
      end
    end
    describe "when signed in" do
      describe "and not authorized" do
        before do
          @user = FactoryGirl.create :login
          sign_in @user
        end
        it "should list files" do
          get :index
          response.should redirect_to "https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&client_id=840123515072-bi3cnnt361ek7tnqfgbc05npt4h096k8.apps.googleusercontent.com&redirect_uri=http://bindery.cocupu.com:3001/drives&response_type=code&scope=https://www.googleapis.com/auth/drive.readonly%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/userinfo.profile&user_id="
        end
      end
      describe "and authorized" do
        before do
          @user = FactoryGirl.create :login
          sign_in @user
          @files = [stub('file1'), stub('file2')]
          controller.should_receive(:authorized?).and_return(true)
          mock_client = stub("Api client")
          mock_client.should_receive(:execute!).with(:api_method => kind_of(Google::APIClient::Method)).and_return(stub("result", :data => stub("data", :items=>@files)))
          mock_client.stub(:authorization).and_return(stub("authorization", :update_token! => true, :refresh_token=>false, :access_token=>'131', :expires_in => '9999', :issued_at=>'34234'))
          controller.stub(:api_client).and_return(mock_client)
        end
        it "should list files" do
          get :index
          response.should be_success
          # it returns a list of files, see: https://developers.google.com/drive/v1/reference/files
          assigns[:files].should == @files
        end
      end
    end
  end

end
