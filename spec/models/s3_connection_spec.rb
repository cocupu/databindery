require 'spec_helper'

describe S3Connection do
  describe "as_json" do
    it "should not return secret_access_key" do
      subject.as_json.should_not have_key("secret_access_key")
    end
  end
end
