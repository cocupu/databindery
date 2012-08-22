require 'spec_helper'

describe Model do
  before do
    subject.name = "Test Name"
  end

  it "should have many fields" do
    subject.owner = Identity.create
    subject.fields << {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
    subject.fields << {:code=>'two', :name=>'Two', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
    subject.save!
    subject.reload.fields.first.should == {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
  end

  describe "associations" do
    before do
      #TODO associations need a label so that name can be an internal code.
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

    it "should not allow an association to be named undefined" do
      subject.associations << {type: 'Has One', name: 'undefined', references: 77}
      subject.owner = Identity.create
      subject.should_not be_valid
      subject.errors.full_messages.should == ["Associations name can't be 'undefined'"]
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

  it "should validate that label is a field" do
    subject.owner = Identity.create
    subject.label = "title"
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Label must be a field"]
#    subject.fields
  end

  it "should belong to an identity" do
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end
end
