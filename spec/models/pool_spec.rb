require 'spec_helper'

describe Pool do
  it "should belong to an identity" do
    subject.short_name = 'short_name'
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
  end
  
  it "should create a persistent_id when created" do
    subject.persistent_id.should be_nil
    # Make the pool valid to save...
      subject.short_name = 'short_name'
      subject.owner = FactoryGirl.create(:identity)
    subject.save!
    subject.persistent_id.should_not be_nil
  end
  
  describe "#for_identity" do
    before do
      @pool = FactoryGirl.create(:pool)
    end
    describe "for a pool owner" do
      it "should return all the pools" do
        Pool.for_identity(@pool.owner).should == [@pool]
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
        it "should return all the pools" do
          Pool.for_identity(@pool.owner).should == [@pool]
        end
      end
      describe "for a user with edit-access on the pool" do
        before do
          AccessControl.create!(identity: @non_owner, pool: @pool, access: 'EDIT')
        end
        it "should return all the pools" do
          Pool.for_identity(@pool.owner).should == [@pool]
        end
      end
      it "should return an empty set" do
        Pool.for_identity(@non_owner) == []
      end
    end
  end
  
  describe "perspectives" do
    before do
      @exhibit1 = FactoryGirl.create(:exhibit)
      @exhibit2 = FactoryGirl.create(:exhibit)
      subject.exhibits = [@exhibit1, @exhibit2]
      subject.save
    end
    it "should return the exhibits" do
      subject.perspectives.should == [subject.generated_default_perspective, @exhibit1, @exhibit2]
    end
    
    describe "default perspective" do
      describe "when a default has not been explicitly set" do
        it "should return the generated default perspective for the pool" do
          subject.default_perspective.should == subject.generated_default_perspective
        end
      end
      describe "when a default has been explicitly set" do
        before do
          subject.chosen_default_perspective = @exhibit1
        end
        it "should return the one that has been explicitly set" do
          subject.default_perspective.should == @exhibit1
        end
      end
    end
    describe "generated_default_perspective" do
      before do
        @model1 = FactoryGirl.create(:model, pool: subject)
        @model1.fields << {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
        @model1.fields << {:code=>'two', :name=>'Two', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
        @model1.save
        subject.models << @model1
      end
      it "should generate an Exhibit whose facet and index fields are all fields from all Models" do
        e = subject.generated_default_perspective
        e.should be_kind_of Exhibit
        e.facets.should == ["description","one", "two"]
        e.index_fields.should == ["description","one", "two"]
      end
      it "should not merge duplicate fields" do
        subject.stub(:all_fields).and_return([{"code"=>"collection_location", "name"=>"Collection Location"}, {"code"=>"date_from", "name"=>"Date from"}, {"name"=>"Date from", "type"=>"date", "uri"=>"", "code"=>"date_from"}, {"code"=>"date_to", "name"=>"Date to"}, {"name"=>"Date to", "type"=>"date", "uri"=>"", "code"=>"date_to"}])
        p subject.models
        e = subject.generated_default_perspective
        e.facets.should == ["collection_location", "date_from", "date_to"]
        e.index_fields.should == ["collection_location", "date_from", "date_to"]
      end
    end
  end

  describe "file_store" do
    let(:pool) {FactoryGirl.create(:pool)}
    subject {pool.file_store}
    it "should use the app default S3 connection" do
      subject.should be_instance_of(Bindery::Storage::S3::FileStore)
      subject.connection.should == Bindery::Storage::S3.default_connection
    end
    it "should use a bucket that is unique to the pool" do
      subject.bucket_name.should == pool.persistent_id
    end
  end
  
  describe "short_name" do
    before do
      subject.owner = Identity.create
    end
    it "Should accept letters, numbers, underscore and hyphen" do
      subject.short_name="short-name_123"
      subject.should be_valid
    end
    it "Should not accept spaces or symbols" do
      subject.short_name="short name_123"
      subject.should_not be_valid
      %w[. & * ) / = # ; : \\ @ \[ ?].each do |sym|
        subject.short_name="short#{sym}name_123"
        subject.should_not be_valid
      end
    end
    it "should get downcased" do
      subject.short_name="Short-Name"
      subject.short_name.should == 'short-name'
    end
  end
  
  

end
