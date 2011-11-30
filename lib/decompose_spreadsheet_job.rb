class DecomposeSpreadsheetJob < ProcessChainJob

  def perform
    @chattel = Chattel.find(input[:spreadsheet_id])
    detect_type(input[:file]).new(input[:file])
  end

  def detect_type(file_name)
  end

end
