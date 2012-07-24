class Worksheet < ActiveRecord::Base
  has_many :rows, :class_name=>'SpreadsheetRow'
  #one :spreadsheet, :class_name=>'Cocupu::Spreadsheet' #, index: true

  def reify(mapping_template)
    ConcurrentJob.create().enqueue_collection(ReifyEachSpreadsheetRowJob, self.rows, {:template=>mapping_template })
  end
end
