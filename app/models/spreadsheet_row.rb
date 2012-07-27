class SpreadsheetRow < ActiveRecord::Base
  has_one :job_log_item
  belongs_to :worksheet
  serialize :values, Array
  default_scope order("row_number asc")

end
