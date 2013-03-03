require 'spec_helper'

describe Bindery::Storage::S3 do
  it "should have default connection" do
    conn = subject.default_connection 
    conn.should be_instance_of S3Connection
    conn.access_key_id.should == AWS.config.access_key_id
    conn.secret_access_key.should == AWS.config.secret_access_key
  end
end
