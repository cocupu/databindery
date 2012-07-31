require 'spec_helper'

describe Ability do
  describe "models" do
    before do
      @model = FactoryGirl.create :model
    end
    it "are readable by their owner" do
      ability = Ability.new(@model.owner)
      ability.can?(:read, @model).should be_true
    end
    it "are not readable by a non-owner" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @model).should_not be_true
    end
  end
  describe "nodes" do
    before do
      @node = FactoryGirl.create :node
    end
    it "are readable by the owner of the pool they are in" do
      ability = Ability.new(@node.pool.owner)
      ability.can?(:read, @node).should be_true
    end
    it "are not readable by a non-owner of the pool" do
      ability = Ability.new(FactoryGirl.create :identity)
      ability.can?(:read, @node).should_not be_true
    end
  end
end
