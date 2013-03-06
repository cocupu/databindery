require 'spec_helper'

describe Bindery::Storage::S3 do
  it "should have default connection" do
    conn = subject.default_connection 
    conn.should be_instance_of S3Connection
    conn.access_key_id.should == AWS.config.access_key_id
    conn.secret_access_key.should == AWS.config.secret_access_key
  end
  describe "key_from_filepath" do
    it "should extract the object key from the filepath from response that direct upload returns" do
      filepath = "/f53e6340-66e4-0130-8d3f-442c031da886/uploads%2F20130306T1135Z_7f3c6aa9d5d5a164e047281b6603bed7%2FDSC_0426-7.jpg"
      key = Bindery::Storage::S3.key_from_filepath(filepath,bucket:"f53e6340-66e4-0130-8d3f-442c031da886")
      key.should == "uploads/20130306T1135Z_7f3c6aa9d5d5a164e047281b6603bed7/DSC_0426-7.jpg"
    end
  end
end
