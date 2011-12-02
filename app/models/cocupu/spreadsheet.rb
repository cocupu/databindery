### Non-namespaced version is used by roo
class Cocupu::Spreadsheet < Chattel
  has_many :rows, :class_name=>'SpreadsheetRow'

  def reify(mapping_template)
    ConcurrentJob.new().enqueue_collection(ReifyEachSpreadsheetRowJob, self.rows, {:template=>mapping_template })
  end
end
