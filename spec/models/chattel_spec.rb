require 'spec_helper'

describe Chattel do
  it "should have attachment" do
    Chattel.new.attachment.exists?.should be_false
    @chattel = Chattel.create(owner: FactoryGirl.create(:identity), attachment: Rack::Test::UploadedFile.new(Rails.root + 'spec/fixtures/images/rails.png', 'image/png'))
    @chattel.attachment.exists?.should be_true
    Chattel.find(@chattel.id).attachment.exists?.should be_true
  end

  it "should know if it's a spreadsheet" do
    Chattel.new.spreadsheet?.should be_false
    chattel = Chattel.create(:attachment => Rack::Test::UploadedFile.new(Rails.root + 'spec/fixtures/images/rails.png', 'image/png'))
    chattel.spreadsheet?.should be_false
    chattel = Cocupu::Spreadsheet.create(owner: FactoryGirl.create(:identity), attachment:  Rack::Test::UploadedFile.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls', 'application/vnd.ms-excel'))
    chattel.spreadsheet?.should be_true
    
  end
end
