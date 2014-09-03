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
      it "should return all the models in the pool plus the File Entity model" do
        models = Model.for_identity(@pool.owner)
        models.size.should == 5
        models.should include(Model.file_entity)
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

  describe "update_attributes" do
    it "should update" do
        params = {name:"Collection", label:"collection_name_<set_by_franklin>", fields_attributes:[{"code"=>"submitted_by", "name"=>"Submitted By"}, {"code"=>"collection_name_<set_by_franklin>", "name"=>"Collection Name        <set by Franklin>"}, {"code"=>"media_<select>", "name"=>"Media        <select>"}, {"code"=>"#_of_media", "name"=>"# of Media"}, {"code"=>"collection_owner", "name"=>"Collection Owner"}, {"code"=>"collection_location", "name"=>"Collection Location"}, {"code"=>"program_title_english", "name"=>"Program Title English"}, {"code"=>"main_text_title_tibetan_<select>", "name"=>"Main Text Title Tibetan        <select>"}, {"code"=>"main_text_title_english_<select>", "name"=>"Main Text Title English        <select>"}, {"code"=>"program_location_<select>", "name"=>"Program Location        <select>"}, {"code"=>"date_from_", "name"=>"Date from "}, {"code"=>"date_to", "name"=>"Date to"}, {"code"=>"date_from_", "name"=>"Date from "}, {"code"=>"date_to", "name"=>"Date to"}, {"code"=>"teacher", "name"=>"Teacher"}, {"code"=>"restricted?_<select>", "name"=>"Restricted?        <select>"}, {"code"=>"original_recorded_by_<select>", "name"=>"Original Recorded By        <select>"}, {"code"=>"copy_or_original_<select>", "name"=>"Copy or Original        <select>"}, {"code"=>"translation_languages", "name"=>"Translation Languages"}, {"code"=>"notes", "name"=>"Notes"}, {"code"=>"post-digi_notes", "name"=>"Post-Digi Notes"}, {"code"=>"post-production_notes", "name"=>"Post-Production Notes"}], allow_file_bindings: true, associations_attributes: [], code:nil, created_at:"2013-06-17T01:43:35Z",  id: 4, identity_id: 1}
        subject.update_attributes( params )
        subject.label.should == "collection_name_<set_by_franklin>"
        subject.associations.should == []
    end
  end
  
  it "should have a file entity" do
    owner = FactoryGirl.create :identity
    file_entity = Model.file_entity
    file_entity.should be_kind_of Model
    file_entity.code.should == Model::FILE_ENTITY_CODE
    file_entity.fields.first.code.should == 'file_name'
    file_entity.fields.last.code.should == "content_type"
    file_entity.label.should == 'file_name'
  end

  it "should have many fields" do
    subject.owner = Identity.create
    subject.pool = FactoryGirl.create :pool
    field1 =  Field.create(:code=>'one', :name=>'One', :type=>'TextField', :uri=>'dc:name', :multivalue=>true)
    field2 = Field.create(:code=>'two', :name=>'Two', :type=>'TextField', :uri=>'dc:name', :multivalue=>true)
    subject.fields << field1
    subject.fields << field2
    subject.save!
    subject.reload.fields.first.should == field1
  end

  describe "associations" do
    let(:other_model) { FactoryGirl.create(:model) }
    let(:association1) {FactoryGirl.create(:association, name: 'talk', label: "Talk", multivalue:false, references: other_model.id)}
    let(:association2) {FactoryGirl.create(:association, name: 'authors', label: "Authors", multivalue:true, references: 39)}
    let(:association3) {FactoryGirl.create(:association, name: 'tracks', label: "Tracks", multivalue:true, references: 40)}
    let(:association4) {FactoryGirl.create(:association, name: 'members', label: "Members", multivalue:true, references: 41)}
    before do
      subject.associations << association1
      subject.associations << association2
      subject.associations << association3
      subject.associations << association4
    end
    it "should have many associations" do
      subject.associations.should == [association1, association2, association3, association4]
    end

    it "should not allow an association to be named undefined" do
      subject.associations << OrderedListAssociation.create(name: 'undefined', references: 77)
      subject.owner = Identity.create
      subject.pool = FactoryGirl.create :pool
      subject.should_not be_valid
      subject.errors.full_messages.should == ["Associations name can't be 'undefined'"]
    end

    it "should have labels" do
      subject.associations.map(&:label).should include("Talk", "Authors")
    end

    it "should have model" do
      subject.associations.first.model.should == other_model
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
