require 'spec_helper'

describe Chattel do
  it "should have attachment" do
    Chattel.new.attachment.file?.should be_false
    @chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/images/rails.png'))
    @chattel.attachment.file?.should be_true
    Chattel.find(@chattel.id).attachment.file?.should be_true
  end

  it "should know if it's a spreadsheet" do
    Chattel.new.spreadsheet?.should be_false
    chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/images/rails.png'))
    chattel.spreadsheet?.should be_false
    chattel = Chattel.create(:attachment => File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls'))
    chattel.spreadsheet?.should be_true
    
  end
end
