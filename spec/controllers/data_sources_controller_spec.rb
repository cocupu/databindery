require 'spec_helper'

describe DataSourcesController do
  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @not_my_pool = FactoryGirl.create :pool
    @my_s3 = FactoryGirl.create(:s3_connection, pool: @pool)
    @not_my_s3 = FactoryGirl.create(:s3_connection, pool: @not_my_pool)
  end
  describe "index" do
    describe "when not logged on" do
      subject { get :index }
      it "should show nothing" do
        response.should  be_successful
        assigns[:s3_connections].should be_nil
      end
    end

    describe "when logged on" do
      before do
        sign_in @identity.login_credential
      end
      it "should be successful" do
        get :index, :identity_id=>@identity.short_name, :pool_id=>@pool.short_name
        response.should  be_successful
        assigns[:s3_connections].size.should == 1
      end
      it "should return json" do
        get :index, :identity_id=>@identity.short_name, :pool_id=>@pool.short_name, :format=>:json
        response.should  be_successful
        # json = JSON.parse(response.body)
        response.body.should == {"s3Connections" => 
          [@my_s3.as_json.merge(url: identity_pool_s3_connection_path(identity_id: @identity, pool_id: @pool, id: @my_s3.id))]
          }.to_json
      end
    end
  end
end