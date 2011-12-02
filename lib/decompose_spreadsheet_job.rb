class DecomposeSpreadsheetJob < Struct.new(:spreadsheet_id, :log)

  def enqueue(job)
    log.update_attribute(:status, 'ENQUEUE')
  end

  def perform
    log.update_attribute(:status, 'PROCESSING')
    Chattel.find(spreadsheet_id).update_attribute(:_type,"Cocupu::Spreadsheet") #do a typecast
    @chattel = Cocupu::Spreadsheet.find(spreadsheet_id)
    spreadsheet = detect_type(@chattel).new(@chattel.attachment.path)
    spreadsheet.first_row.upto(spreadsheet.last_row) do |row_idx|
      stored_row = []
      spreadsheet.first_column.upto(spreadsheet.last_column) do |col_idx|
        cell = spreadsheet.cell(row_idx, col_idx) 
        if cell.is_a?(DateTime) || cell.is_a?(Date)
           stored_row << cell.to_time
        else
          stored_row << cell
        end
      end
      SpreadsheetRow.create(:spreadsheet => @chattel , :row_number => row_idx, :job_log_item => @log, :values => stored_row)
    end
  end


  def success(job)
    log.update_attribute(:status, 'SUCCESS')
  end

  def error(job, exception)
    log.status = 'ERROR'
    log.message = exception
    log.save!
  end

  def failure
    log.update_attribute(:status, 'FAILURE')
  end

  def detect_type(chattel)
    case chattel.attachment_content_type
    when "application/vnd.ms-excel"
      Excel
    end
    
  end

end
