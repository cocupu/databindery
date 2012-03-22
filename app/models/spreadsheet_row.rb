class SpreadsheetRow
  include Ripple::Document
  one :job_log_item
  #one :worksheet#, index: true
  many :values
  property :row_number, Integer

  class Value
    include Ripple::EmbeddedDocument
    property :value, Object
    embedded_in :spreadsheet_row
  end
end
