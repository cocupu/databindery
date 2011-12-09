class Worksheet
  include Mongoid::Document
  has_many :rows, :class_name=>'SpreadsheetRow'
  belongs_to :spreadsheet, :class_name=>'Cocupu::Spreadsheet', index: true
  field :name

  def reify(mapping_template)
    ConcurrentJob.create().enqueue_collection(ReifyEachSpreadsheetRowJob, self.rows, {:template=>mapping_template })
  end
end
