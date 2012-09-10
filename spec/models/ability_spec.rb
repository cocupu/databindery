require 'spec_helper'

describe Ability do
  describe "pools" do
    before do
      @pool = FactoryGirl.create :pool
    end
    it "are readable by their owner" do
      ability = Ability.new(@pool.owner)
      ability.can?(:read, @pool).should be_true
    end
    it "are not readable by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @pool).should_not be_true
    end
    it "can be updated by an owner" do
      ability = Ability.new(@pool.owner)
      ability.can?(:update, @pool).should be_true
    end
    it "can't be updated by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:update, @pool).should_not be_true
    end
    it "can be created by a logged in user" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:create, Pool).should be_true
    end
    it "can't be created by a not logged in user" do
      ability = Ability.new(nil)
      ability.can?(:create, Pool).should_not be_true
    end
  end
  describe "mapping_template" do
    before do
      @mapping_template = FactoryGirl.create(:mapping_template)
    end
    it "are readable by their owner" do
      ability = Ability.new(@mapping_template.pool.owner)
      ability.can?(:read, @mapping_template).should be_true
    end
    it "are not readable by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @mapping_template).should_not be_true
    end
    it "can be updated by an owner" do
      ability = Ability.new(@mapping_template.pool.owner)
      ability.can?(:update, @mapping_template).should be_true
    end
    it "can't be updated by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:update, @mapping_template).should_not be_true
    end
    it "can be created by a logged in user" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:create, MappingTemplate).should be_true
    end
    it "can't be created by a not logged in user" do
      ability = Ability.new(nil)
      ability.can?(:create, MappingTemplate).should_not be_true
    end
  end
  describe "models" do
    before do
      @model = FactoryGirl.create :model
    end
    it "are readable by their owner" do
      ability = Ability.new(@model.pool.owner)
      ability.can?(:read, @model).should be_true
    end
    it "are not readable by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @model).should_not be_true
    end
    it "can be updated by an owner" do
      ability = Ability.new(@model.pool.owner)
      ability.can?(:update, @model).should be_true
    end
    it "can't be updated by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:update, @model).should_not be_true
    end
    it "can be created by a logged in user" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:create, Model).should be_true
    end
    it "can't be created by a not logged in user" do
      ability = Ability.new(nil)
      ability.can?(:create, Model).should_not be_true
    end
  end
  describe "nodes" do
    before do
      @node = FactoryGirl.create :node
    end
    it "can be created by a logged in user" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:create, Node).should be_true
    end
    it "are readable by the owner of the pool they are in" do
      ability = Ability.new(@node.pool.owner)
      ability.can?(:read, @node).should be_true
    end
    it "are not readable by a non-owner of the pool" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @node).should_not be_true
    end
    it "can be updated by an owner" do
      ability = Ability.new(@node.pool.owner)
      ability.can?(:update, @node).should be_true
    end
    it "can't be updated by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:update, @node).should_not be_true
    end
  end

  describe "exhibits" do
    before :all do
      @exhibit = FactoryGirl.create :exhibit
      @owner = Ability.new(@exhibit.pool.owner)
      @non_owner = Ability.new(FactoryGirl.create :identity)
    end
    it "are readable by the owner of the pool they are in" do
      @owner.can?(:read, @exhibit).should be_true
    end
    it "are not readable by a non-owner of the pool" do
      @non_owner.can?(:read, @exhibit).should_not be_true
    end
    it "are editable by the owner of the pool they are in" do
      @owner.can?(:edit, @exhibit).should be_true
    end
    it "are not editable by a non-owner of the pool" do
      @non_owner.can?(:edit, @exhibit).should_not be_true
    end
    it "are updateable by the owner of the pool they are in" do
      @owner.can?(:update, @exhibit).should be_true
    end
    it "are not updateable by a non-owner of the pool" do
      @non_owner.can?(:update, @exhibit).should_not be_true
    end
    it "should be creatable by anyone" do
      @non_owner.can?(:create, Exhibit).should be_true
    end
    it "should not be creatable by anonymous" do
      ability = Ability.new(Identity.new)
      ability.can?(:create, Exhibit).should_not be_true
    end
  end
end
