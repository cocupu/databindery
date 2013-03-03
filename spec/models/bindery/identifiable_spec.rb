require 'spec_helper'

describe Bindery::Identifiable do
  class DummyClass 
    attr_accessor :persistent_id
  end

  before(:all) do
    @identifiable = DummyClass.new
    @identifiable.extend Bindery::Identifiable
  end 
  
  describe "generate_uuid" do
    it "should set a persistent_id on object" do
      @identifiable.persistent_id.should be_nil
      @identifiable.generate_uuid
      @identifiable.persistent_id.should_not be_nil
    end
  end
end
