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
        e.facets.should == ["model_name","description","one", "two"]
        e.index_fields.should == ["model_name","description","one", "two"]
      end
      it "should not merge duplicate fields" do
        subject.stub(:all_fields).and_return([{"code"=>"collection_location", "name"=>"Collection Location"}, {"code"=>"date_from", "name"=>"Date from"}, {"name"=>"Date from", "type"=>"date", "uri"=>"", "code"=>"date_from"}, {"code"=>"date_to", "name"=>"Date to"}, {"name"=>"Date to", "type"=>"date", "uri"=>"", "code"=>"date_to"}])
        e = subject.generated_default_perspective
        e.facets.should == ["collection_location", "date_from", "date_to"]
        e.index_fields.should == ["collection_location", "date_from", "date_to"]
      end
    end
  end
  
  describe "all_associations" do
    before do
      @model1 = FactoryGirl.create(:model)
      @model2 = FactoryGirl.create(:model)
      @model1.associations << {type: 'Has One', code: "talk", name: "Talk", references: 38}
      @model1.associations << {type: 'Has Many', code: "authors", name: "Authors", references: 39}
      @model2.associations << {type: 'Ordered List', code: "tracks", name: "Tracks", references: 40}
      @model2.associations << {type: 'Unordered List', code: "members", name: "Members", references: 41}
      @model2.associations << {type: 'Has Many', code: "authors", name: "Authors", references: 39}
      subject.models << @model1
      subject.models << @model2
    end
    it "should return all Model associations in the pool" do
      subject.all_associations.should == [{type: 'Has One', code: "talk", name: "Talk", references: 38},{type: 'Has Many', code: 'authors', name: "Authors", references: 39}, {type: 'Ordered List', code: 'tracks', name: "Tracks", references: 40}, {type: 'Unordered List', code: 'members', name: "Members", references: 41}, {type: 'Has Many', code: 'authors', name: "Authors", references: 39}]
    end
    it "should support filtering for uniqueness based on association code" do
      subject.all_associations().length.should == 5
      subject.all_associations(unique: true).length.should == 4
      subject.all_associations(unique: true).should == [{type: 'Has One', code: "talk", name: "Talk", references: 38},{type: 'Has Many', code: 'authors', name: "Authors", references: 39}, {type: 'Ordered List', code: 'tracks', name: "Tracks", references: 40}, {type: 'Unordered List', code: 'members', name: "Members", references: 41}]
    end
  end

  it "should have many audience categories" do
    subject.audience_categories.should == []
    @aud = AudienceCategory.new
    subject.audience_categories << @aud
    subject.audience_categories.should == [@aud]
  end

  describe "audiences" do
    before do
      @identity = FactoryGirl.create :identity
      @cat1 =  FactoryGirl.create :audience_category, pool:subject
      @cat2 =  FactoryGirl.create :audience_category
      @aud1 =  FactoryGirl.create :audience, audience_category:@cat1, name:"Audience 1"
      @aud2 =  FactoryGirl.create :audience, audience_category:@cat1, name:"Audience 2"
      @aud3 =  FactoryGirl.create :audience, audience_category:@cat2, name:"Audience 3"
      @aud1.members << @identity
      @aud3.members << @identity
      subject.audience_categories << @cat1 << @cat2
    end
    describe "audiences_for_identity" do
      it "should return all the applicable audiences for the given identity" do
        subject.audiences_for_identity(@identity).should == [@aud1, @aud3]
      end
    end
    describe "apply_solr_params_for_identity" do
      it "should aggregate solr_params from all applicable audiences" do
        @aud1.update_attributes filters_attributes:[{field_name:"subject", operator:"+", values:["foo","bar"]}]
        @aud3.update_attributes filters_attributes:[{filter_type:"RESTRICT", field_name:"field2", operator:"-", values:["baz"]}]
        solr_params, user_params = subject.apply_solr_params_for_identity(@identity, {}, {})
        solr_params.should == {fq: ["-field2_ssi:\"baz\"", "subject_ssi:\"foo\" OR subject_ssi:\"bar\""]}
      end
    end
  end
  
  describe "default_bucket_id" do
    it "should be the pools persistent id" do
      subject.should_receive(:persistent_id).and_return("thepid")
      subject.default_bucket_id.should == "thepid"
    end
  end
  
  describe "bucket" do
    it "should return the pools bucket from s3 connection" do
      subject.default_file_store.should_receive(:bucket).and_return("the bucket")
      subject.bucket.should == "the bucket"
    end
  end
  
  describe "ensure_bucket_initialized" do
    it "should ensure that the pools bucket exists on s3 connection" do
      subject.default_file_store.should_receive(:ensure_bucket_initialized).and_return("the bucket")
      subject.ensure_bucket_initialized.should == "the bucket"
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

  describe "all_fields" do
    before do
      subject.save
      @model1 = FactoryGirl.create(:model, pool: subject)
      @model1.fields << {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
      @model1.fields << {:code=>'two', :name=>'Two', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
      @model1.save
      @model2 = FactoryGirl.create(:model, pool: subject)
      @model2.fields << {:code=>'one', :name=>'One', :type=>'textfield', :uri=>'dc:name', :multivalued=>true}.with_indifferent_access
      @model2.fields << {:code=>'three', :name=>'Three', :type=>'textfield', :uri=>'dc:name', :multivalued=>false}.with_indifferent_access
      @model2.save
      subject.models << @model1
      subject.models << @model2
    end
    it "should return all fields from all models, removing duplicates" do
      subject.all_fields.count.should == 5
      codes = subject.all_fields.map {|f| f["code"]}
      ["model_name","description","one","two","three"].each {|code| codes.should include(code)}
    end
  end
end
