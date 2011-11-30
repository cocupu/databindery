require 'spec_helper'

describe Chattel do
  it "should have attachment" do
    Chattel.new.attachment.file?.should be_false
    @chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/images/rails.png'))
    @chattel.attachment.file?.should be_true
    Chattel.find(@chattel.id).attachment.file?.should be_true
    
  end
end
