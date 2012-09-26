class SpreadsheetRow < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  has_one :job_log_item
  belongs_to :worksheet
  serialize :values, Array
  default_scope order("row_number asc")

end
