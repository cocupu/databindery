require 'spec_helper'
require 'objspace'

describe Node do
  let(:pool) { FactoryGirl.create(:pool) }
  let(:model) { FactoryGirl.create(:model, pool:pool) }

  describe '#import' do
    it "should import all of the records in a source array" do
      count_before = Node.count
      source_records = (1..10).to_a.map { generate_node_of_size(500) }
      Node.import(source_records)
      expect(Node.count).to eq(count_before + source_records.count)
    end
  end
  describe '#import_nodes' do
    it "should import all of the records in a source array" do
      count_before = Node.count
      source_records = (1..2).to_a.map { generate_node_of_size(500) }
      expect(Bindery).to receive(:index)
      expect(Bindery.solr).to receive(:commit)
      Node.import_nodes(source_records)
      expect(Node.count).to eq(count_before + source_records.count)
    end
  end
  describe '#bulk_import_records' do
    it "should import small batches in one chunk" do
      compact_source_records = (1..200).to_a.map { generate_node_of_size(500) }
      expect(Node).to receive(:import)
      Node.bulk_import_records(compact_source_records, pool, model)
    end
    it "should chunk large batches by memory consumption" do
      pending "Inefficiency of Memory size calculations might make this more unwieldy than worthwhile"
      bulky_source_records = [5.24*1000**2, 6*1000**2, 7*1000**2].map{|size| generate_node_of_size(size)}
      expect(Node).to receive(:import).exactly(3).times
      Node.bulk_import_records(bulky_source_records, pool, model)
    end
  end

  def generate_node_of_size(desired_memory_size)
    node = Node.new(pool:pool, model:model)
    node.data = generate_record_of_size(desired_memory_size)
    node
  end

  def generate_record_of_size(desired_memory_size)
    record = {}
    counter = 0
    until ObjectSpace.memsize_of(record) >= desired_memory_size
      counter +=1
      record[counter] = [rand(36**10).to_s(36)]
    end
    record
  end
end