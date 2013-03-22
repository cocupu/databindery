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
                  storage_location_id: "/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg", file_name: "DSC_0549-3.jpg", file_size: "471990", mime_type: "image/jpeg"
                  }}
      s3_obj_metadata_hash = {}
      stub_s3_obj = stub("S3 Object", :metadata=>s3_obj_metadata_hash)
      S3Connection.any_instance.stub(:get).and_return(stub_s3_obj)
      file_entity = FileEntity.register(@pool, params)
      s3_obj_metadata_hash.should == {"filename"=>"DSC_0549-3.jpg", "bindery-pid" => file_entity.persistent_id}
      file_entity.file_entity_type.should == "S3"
      file_entity.binding.should == "https://s3.amazonaws.com/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.storage_location_id.should == "/f542aab0-66e4-0130-8d40-442c031da886/uploads%2F20130305T1425Z_eaf29caae12b6d4a101297b45c46dc2a%2FDSC_0549-3.jpg"
      file_entity.file_name.should == "DSC_0549-3.jpg"
      file_entity.file_size.should == "471990"
      file_entity.mime_type.should == "image/jpeg"
      file_entity.pool.should == @pool
    end
  end
  describe "content type inspectors" do
    subject {Node.new.extend(FileEntity)}
    describe "audio?" do
      it "should test for audio mimetypes" do
        subject.stub(:mime_type).and_return("image/jpeg")
        subject.audio?.should be_false
        ["audio/mp3", "audio/mpeg"].each do |mimetype|
          subject.stub(:mime_type).and_return(mimetype)
          subject.audio?.should be_true
        end
        subject.stub(:mime_type).and_return("image/jpeg")
        subject.audio?.should be_false
      end
    end
    describe "image?" do
      it "should test for image mimetypes" do
        subject.stub(:mime_type).and_return("audio/mpeg")
        subject.image?.should be_false
        ["image/png","image/jpeg", 'image/jpg', 'image/bmp', "image/gif"].each do |mimetype|
          subject.stub(:mime_type).and_return(mimetype)
          subject.image?.should be_true
        end
        subject.stub(:mime_type).and_return("audio/mp3")
        subject.image?.should be_false
      end
    end
    describe "video?" do
      it "should test for video mimetypes" do
        subject.stub(:mime_type).and_return("audio/mpeg")
        subject.video?.should be_false
        ["video/mpeg", "video/mp4", "video/x-msvideo", "video/avi", "video/quicktime"].each do |mimetype|
          subject.stub(:mime_type).and_return(mimetype)
          subject.video?.should be_true
        end
        subject.stub(:mime_type).and_return("audio/mpeg")
        subject.video?.should be_false
      end
    end
    describe "pdf?" do
      it "should test for pdf mimetype" do
        subject.stub(:mime_type).and_return("audio/mpeg")
        subject.pdf?.should be_false
        ["application/pdf"].each do |mimetype|
          subject.stub(:mime_type).and_return(mimetype)
          subject.pdf?.should be_true
        end
        subject.stub(:mime_type).and_return("video/avi")
        subject.pdf?.should be_false
      end
    end
  end
end