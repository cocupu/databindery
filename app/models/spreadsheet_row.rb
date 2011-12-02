class SpreadsheetRow
  include Mongoid::Document
  belongs_to :job_log_item
  belongs_to :spreadsheet, :class_name=>'Cocupu::Spreadsheet'   #TODO add index here.
  field :values
  field :row_number
end
