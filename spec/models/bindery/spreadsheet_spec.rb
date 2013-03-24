require 'spec_helper'

describe Bindery::Spreadsheet do
  it "should have worksheets" do
    ws = Worksheet.new()
    subject.worksheets << ws
    subject.worksheets.should include ws
  end

  it "should belong to a Pool and have a Model" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Model can't be blank", "Pool can't be blank"]
    subject.model = Model.file_entity
    subject.should_not be_valid
    subject.pool = Pool.create
    subject.should be_valid
  end

end
