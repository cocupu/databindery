require 'spec_helper'

describe FileEntity do
  describe '#register' do
    before do
      @identity = FactoryGirl.create :identity
      @pool = FactoryGirl.create :pool, :owner=>@identity
    end
    it "should register remote file as a new FileEntity and return the FileEntity" do
      params = {binding: "https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg",
                data: {
                  storage_location_id: "/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg", file_name: "DSC_0549-3.jpg", file_size: "471990", content_type: "image/jpeg"
                  }}
      file_entity = FileEntity.register(@pool, params)
      file_entity.file_entity_type.should == "S3"
      file_entity.binding.should == "https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.storage_location_id.should == "/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.file_name.should == "DSC_0549-3.jpg"
      file_entity.file_size.should == "471990"
      file_entity.content_type.should == "image/jpeg"
      file_entity.pool.should == @pool
    end
  end
end