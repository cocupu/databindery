class Worksheet < ActiveRecord::Base
  belongs_to :spreadsheet, class_name: 'Bindery::Spreadsheet'
  has_many :rows, class_name: 'SpreadsheetRow'

  def reify(mapping_template, pool)
    start_col = mapping_template.row_start - 1
    work = self.rows[start_col..-1]
    ConcurrentJob.create().enqueue_collection(ReifyEachSpreadsheetRowJob, work, {:template_id=>mapping_template.id, :pool_id=>pool.id })
  end
end
