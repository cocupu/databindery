require 'spec_helper'

describe Pool do
  it "should belong to an identity" do
    subject.short_name = 'short_name'
    subject.should_not be_valid
    subject.errors.full_messages.should == ["Owner can't be blank"]
    subject.owner = Identity.create
    subject.should be_valid
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
        it "should return an exhibit that has all of the pool's fields set in both its facets and index_fields" do
          e = subject.default_perspective
          e.should be_kind_of Exhibit
          all_field_codes = subject.all_fields.map {|f| f["code"]}
          e.facets.should == all_field_codes
          e.index_fields.should == all_field_codes
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
