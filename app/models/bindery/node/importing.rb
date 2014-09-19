module Bindery::Node::Importing
  extend ActiveSupport::Concern

  module ClassMethods
    def bulk_import_records(records, pool, model)
      nodes = records.map {|record| Node.new(pool:pool, model:model, data:record)}
      self.import(nodes)
    end
  end
end
