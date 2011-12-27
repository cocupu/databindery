require 'spec_helper'


describe Cocupu::Config do
  before do
    @conf = Cocupu::Config.new
  end
  it "should return a hash of search fields" do
    @conf.search_fields.should be_kind_of Hash
  end

  it "should return a hash of default_solr_params" do
    @conf.default_solr_params.should be_kind_of Hash
  end

  it "should return a hash of facet_fields" do
    @conf.facet_fields.should be_kind_of Hash
  end

  it "should return max_per_page" do
    @conf.max_per_page.should == 30
  end

  it "should have default_sort_field" do
    @conf.default_sort_field.should be_nil
  end

  it "should have a hash of sort_fields" do
    @conf.sort_fields.should be_kind_of Hash
  end
end
