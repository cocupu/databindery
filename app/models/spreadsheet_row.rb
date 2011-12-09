class SpreadsheetRow
  include Mongoid::Document
  belongs_to :job_log_item
  belongs_to :worksheet, index: true
  field :values
  field :row_number
end
