require 'spec_helper'

describe Model do
  before do
    subject.name = "Test Name"
  end

  it "should have many fields" do
    subject.fields = {'one' => {:name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}}
    subject.fields['two'] = {:name=>'Two', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
    subject.fields['one'].should == {:name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
  end

  describe "associations" do
    before do
      @other_model = FactoryGirl.create(:model)
      subject.associations << {type: 'Has One', name: 'talk', references: @other_model.id}
      subject.associations << {type: 'Has Many', name: 'authors', references: 39}
      subject.associations << {type: 'Ordered List', name: 'tracks', references: 40}
      subject.associations << {type: 'Unordered List', name: 'members', references: 41}
    end
    it "should have many associations" do
      subject.associations.should == [{type: 'Has One', name: 'talk', references: @other_model.id},
        {type: 'Has Many', name: 'authors', references: 39}, 
        {type: 'Ordered List', name: 'tracks', references: 40}, 
        {type: 'Unordered List', name: 'members', references: 41}]
    end

    it "should have labels" do
      subject.inbound_associations.map(&:label).should include("Has One Talk", "Has Many Authors")
    end

    it "should have model" do
      subject.inbound_associations.first.model.should == @other_model
    end


    it "should have many outbound associations" do
      subject.outbound_associations.should == [{type: 'Ordered List', name: 'tracks', references: 40}, {type: 'Unordered List', name: 'members', references: 41}]
    end
    it "should have many inbound associations" do
      subject.inbound_associations.should == [{type: 'Has One', name: 'talk', references: @other_model.id}, {type: 'Has Many', name: 'authors', references: 39}]
    end
  end

  it "should have a label" do
    subject.label = "title"
    subject.label.should == "title"
  end

  it "should belong to an identity" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end
end
