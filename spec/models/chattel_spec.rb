require 'spec_helper'

describe Chattel do
  it "should have attachment" do
    @chattel = Chattel.create(owner: FactoryGirl.create(:identity))
    @chattel.attach(File.new(Rails.root + 'spec/fixtures/images/rails.png').read, 'image/png', 'spec/fixtures/images/rails.png')
    @chattel.attachment.should_not be_nil
    @chattel.save!
    Chattel.find(@chattel.id).attachment.should_not be_nil
  end

  it "should know if it's a spreadsheet" do
    Chattel.new.spreadsheet?.should be_false
    chattel = Chattel.create(owner: FactoryGirl.create(:identity))
    chattel.attach(File.new(Rails.root + 'spec/fixtures/images/rails.png').read, 'image/png', 'spec/fixtures/images/rails.png')
    chattel.spreadsheet?.should be_false
    chattel = Cocupu::Spreadsheet.create(owner: FactoryGirl.create(:identity))
    chattel.attach(File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls').read, 'application/vnd.ms-excel', 'dechen_rangdrol_archives_database.xls')
    chattel.spreadsheet?.should be_true
    
  end
end
