class SpreadsheetRow
  include Mongoid::Document
  belongs_to :job_log_item
  belongs_to :chattel
end
