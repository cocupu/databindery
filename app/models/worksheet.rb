class Worksheet
  include Ripple::Document
  many :rows, :class_name=>'SpreadsheetRow'
  one :spreadsheet, :class_name=>'Cocupu::Spreadsheet' #, index: true
  property :name, String

  alias_method :id, :key

  def reify(mapping_template)
    ConcurrentJob.create().enqueue_collection(ReifyEachSpreadsheetRowJob, self.rows, {:template=>mapping_template })
  end
end
