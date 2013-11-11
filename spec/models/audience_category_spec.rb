require 'spec_helper'

describe AudienceCategory do
  it "should have many audiences" do
    subject.audiences.should == []
    @aud = Audience.new
    subject.audiences << @aud
    subject.audiences.should == [@aud]
  end
  it "should accept nested attributes for audiences" do
    @aud1 = Audience.create!
    @aud2 = Audience.create!
    subject.update_attributes audiences_attributes: [{name:"Level One"}, {id: @aud2.id}, {id: @aud1.id}]
    subject.save
    subject.audiences.first.should == @aud1.reload
    subject.audiences[1].should == @aud2.reload
    subject.audiences[2].name.should == "Level One"
    to_delete = subject.audiences[2]
    subject.update_attributes audiences_attributes: [{id: to_delete.id, "_destroy"=>"1"}]
    subject.audiences.count.should == 2
    subject.audiences.should == [@aud1, @aud2]
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
  describe "json" do
    it "should include associations" do
      subject.update_attributes name: "The Category", description:"A description", audiences_attributes:[{name:"Level One"}, {name:"Level Two"}]
      subject.as_json["name"].should == "The Category"
      subject.as_json["description"].should == "A description"
      subject.audiences.count.should == 2
      subject.as_json["audiences"].should == subject.audiences.as_json
    end
  end

end