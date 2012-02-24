class DecomposeSpreadsheetJob < Struct.new(:spreadsheet_id, :log)

  def enqueue(job)
    log.update_attribute(:status, 'ENQUEUE')
  end

  def perform
    log.update_attribute(:status, 'PROCESSING')
    @chattel = Cocupu::Spreadsheet.find(spreadsheet_id)
    tmpfile = file = Tempfile.new(['cocupu', '.'+@chattel.attachment_extension], :encoding => 'ascii-8bit')
    tmpfile.write(@chattel.attachment.read)
    spreadsheet = detect_type(@chattel).new(tmpfile.path)
    spreadsheet.sheets.each do |worksheet|
      ingest_worksheet(spreadsheet, worksheet, @chattel)
    end
puts "Worksheets: #{@chattel.worksheets}"
    @chattel.save #Saves associated worksheets
    tmpfile.close
    tmpfile.unlink
  end

  def ingest_worksheet(spreadsheet, worksheet, file)
    sheet = Worksheet.create(:name=>worksheet)
    spreadsheet.first_row(worksheet).upto(spreadsheet.last_row(worksheet)) do |row_idx|
      ingest_row(spreadsheet, worksheet, sheet, row_idx)
    end
    sheet.save #Saves associated rows
    file.worksheets << sheet
  end

  def ingest_row(spreadsheet, worksheet, sheet, row_idx)
    stored_row = []
    spreadsheet.first_column(worksheet).upto(spreadsheet.last_column(worksheet)) do |col_idx|
      cell = spreadsheet.cell(row_idx, col_idx, worksheet) 
      if cell.is_a?(DateTime) || cell.is_a?(Date)
         stored_row << cell.to_time
      else
        stored_row << cell
      end
    end
    row = SpreadsheetRow.create(:row_number => row_idx, :job_log_item => @log, :values => stored_row.map{|v| SpreadsheetRow::Value.new(:value=>v)})
    sheet.rows << row
  end

  def success(job)
    log.update_attributes(:status =>'SUCCESS', :message=>'') ### clear message that may have been from a previous failure.
  end

  def error(job, exception)
    log.status = 'ERROR'
    log.message = "#{exception.message} (#{exception.class})" + exception.backtrace.join("\n")
    log.save!
  end

  def failure
    log.update_attribute(:status, 'FAILURE')
  end

  def detect_type(chattel)
    case chattel.attachment_content_type
    when "application/vnd.ms-excel"
      Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      Openoffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
    
  end

end
