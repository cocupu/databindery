require 'spec_helper'

describe Bindery::Storage::S3::FileStore do
  it "should use the app default connection" do
    subject.connection.should == Bindery::Storage::S3.default_connection
  end
  describe "with s3 connection" do
    before do
      @stub_bucket = "StubBucket:foo"
      @buckets_collection = {"foo"=>@stub_bucket}
      @stub_connection = stub(buckets: @buckets_collection)
      subject.stub(:connection).and_return(stub(conn: @stub_connection))
    end
    it "corresponds to one S3 bucket" do
      # TODO: This should probably be rewritten. - MZ
      @stub_bucket.should_receive(:exists?).and_return(false)
      @buckets_collection.should_receive(:create).with("foo", {:acl=>:bucket_owner_full_control})
      subject.bucket_name = "foo" 
      subject.bucket.should == subject.connection.conn.buckets["foo"]
    end
  end
end
