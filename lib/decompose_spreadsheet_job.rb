class DecomposeSpreadsheetJob < Struct.new(:spreadsheet_id, :log)

  def enqueue(job)
    log.update_attribute(:status, 'ENQUEUE')
  end

  def perform
    log.update_attribute(:status, 'PROCESSING')
    Chattel.find(spreadsheet_id).update_attribute(:_type,"Cocupu::Spreadsheet") #do a typecast
    @chattel = Cocupu::Spreadsheet.find(spreadsheet_id)
    spreadsheet = detect_type(@chattel).new(@chattel.attachment.path)
    spreadsheet.sheets.each do |worksheet|
      ingest_worksheet(spreadsheet, worksheet, @chattel)
    end
  end

  def ingest_worksheet(spreadsheet, worksheet, file)
    sheet = Worksheet.create(:spreadsheet=>file, :name=>worksheet)
    spreadsheet.first_row(worksheet).upto(spreadsheet.last_row(worksheet)) do |row_idx|
      ingest_row(spreadsheet, worksheet, sheet, row_idx)
    end
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
    SpreadsheetRow.create(:worksheet => sheet , :row_number => row_idx, :job_log_item => @log, :values => stored_row)
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
