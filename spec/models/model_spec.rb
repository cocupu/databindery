require 'spec_helper'

describe Model do
  before do
    subject.name = "Test Name"
  end


  describe "#for_identity" do
    before do
      @pool = FactoryGirl.create(:pool_with_models)
      @pool.models.size.should == 5
    end
    describe "for a pool owner" do
      it "should return all the models in the pool" do
        Model.for_identity(@pool.owner).size.should == 5
      end
    end
    describe "for a non-pool owner" do
      before do
        @non_owner = FactoryGirl.create(:identity)
      end
      describe "for a user with read-access on the pool" do
        before do
          AccessControl.create!(identity: @non_owner, pool: @pool, access: 'READ')
        end
        it "should return all the models in the pool" do
          Model.for_identity(@non_owner).size.should == 5
        end
      end
      describe "for a user with edit-access on the pool" do
        before do
          AccessControl.create!(identity: @non_owner, pool: @pool, access: 'EDIT')
        end
        it "should return all the models in the pool" do
          Model.for_identity(@non_owner).size.should == 5
        end
      end
      it "should return an empty set" do
        Model.for_identity(@non_owner) == []
      end
    end
  end

  it "should have a file entity" do
    owner = FactoryGirl.create :identity
    file_entity = Model.file_entity
    file_entity.should be_kind_of Model
    file_entity.code.should == Model::FILE_ENTITY_CODE
    file_entity.fields.should == [{'code' => 'file_name', 'type'=>'textfield', "name"=>"Filename"}]
    file_entity.label.should == 'file_name'
  end

  it "should have many fields" do
    subject.owner = Identity.create
    subject.pool = FactoryGirl.create :pool
    subject.fields << {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
    subject.fields << {:code=>'two', :name=>'Two', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
    subject.save!
    subject.reload.fields.first.should == {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}
  end

  describe "associations" do
    before do
      @other_model = FactoryGirl.create(:model)
      subject.associations << {type: 'Has One', name: 'talk', label: "Talk", references: @other_model.id}
      subject.associations << {type: 'Has Many', name: 'authors', label: "Authors", references: 39}
      subject.associations << {type: 'Ordered List', name: 'tracks', label: "Tracks", references: 40}
      subject.associations << {type: 'Unordered List', name: 'members', label: "Members", references: 41}
    end
    it "should have many associations" do
      subject.associations.should == [{type: 'Has One', name: 'talk', label: "Talk", references: @other_model.id},
        {type: 'Has Many', name: 'authors', label: "Authors", references: 39}, 
        {type: 'Ordered List', name: 'tracks', label: "Tracks", references: 40}, 
        {type: 'Unordered List', name: 'members', label: "Members", references: 41}]
    end

    it "should not allow an association to be named undefined" do
      subject.associations << {type: 'Has One', name: 'undefined', references: 77}
      subject.owner = Identity.create
      subject.pool = FactoryGirl.create :pool
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
      subject.outbound_associations.should == [{type: 'Ordered List', name: 'tracks', label: 'Tracks', references: 40}, {type: 'Unordered List', name: 'members', label: 'Members', references: 41}]
    end
    it "should have many inbound associations" do
      subject.inbound_associations.should == [{type: 'Has One', name: 'talk', label: 'Talk', references: @other_model.id}, {type: 'Has Many', name: 'authors', label: 'Authors', references: 39}]
    end
  end

  it "should have a label" do
    subject.label = "title"
    subject.label.should == "title"
  end

  it "should validate that label is a field" do
    subject.owner = Identity.create
    subject.pool = FactoryGirl.create :pool
    subject.label = "title"
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Label must be a field"]
#    subject.fields
  end

  it "should belong to an identity" do
    subject.pool = FactoryGirl.create :pool
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end

  it "should belong to a pool" do
    subject.owner = FactoryGirl.create :identity
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Pool can't be blank"]
    subject.pool = FactoryGirl.create :pool
    subject.should be_valid
  end
  
  describe "allows_file_bindings?" do
    it "should rely on allow_file_bindings attribute" do
      subject.allow_file_bindings = true
      subject.allows_file_bindings?.should == true
      subject.allow_file_bindings = false
      subject.allows_file_bindings?.should == false
    end
  end
end
