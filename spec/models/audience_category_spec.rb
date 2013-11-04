require 'spec_helper'

describe AudienceCategory do
  it "should have many audiences" do
    subject.audiences.should == []
    @aud = Audience.new
    subject.audiences << @aud
    subject.audiences.should == [@aud]
  end
  describe "audience order" do
    before do
      @aud1 = Audience.create!
      @aud2 = Audience.create!
      @aud3 = Audience.create!
    end
    it "should rely on audience position field" do
      subject.audiences.should == []
      @aud = Audience.new
      [@aud3,@aud2,@aud1].each {|a| subject.audiences << a }
      subject.audiences.should == [@aud3,@aud2,@aud1]
      @aud3.position = 2
      @aud2.position = 1
      @aud1.position = 3
      [@aud3,@aud2,@aud1].each {|a| a.save}
      subject.audiences.order.should == [@aud2, @aud3, @aud1]
    end
    it "should default to order or creation" do
      [@aud3,@aud2,@aud1].each {|a| subject.audiences << a }
      subject.audiences.order.should == [@aud1, @aud2, @aud3]
    end
  end

end