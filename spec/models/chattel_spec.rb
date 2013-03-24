require 'spec_helper'

describe Chattel do
  it "should have attachment" do
    @chattel = Chattel.create(owner: FactoryGirl.create(:identity))
    @chattel.attach(File.new(Rails.root + 'spec/fixtures/images/rails.png').read, 'image/png', 'spec/fixtures/images/rails.png')
    @chattel.attachment.should_not be_nil
    @chattel.save!
    Chattel.find(@chattel.id).attachment.should_not be_nil
  end
end
