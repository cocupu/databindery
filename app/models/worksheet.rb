class Worksheet < ActiveRecord::Base
  has_many :rows, :class_name=>'SpreadsheetRow'

  def reify(mapping_template, pool)
    ConcurrentJob.create().enqueue_collection(ReifyEachSpreadsheetRowJob, self.rows, {:template_id=>mapping_template.id, :pool_id=>pool.id })
  end
end
