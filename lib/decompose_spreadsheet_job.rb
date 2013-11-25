class DecomposeSpreadsheetJob < Struct.new(:node_id, :log)
  
  # Note that these jobs are scheduled with Node id, _not_ Node persistent_id
  # This means that decomposed spreadsheets are attached to individual versions of a Node, not the generalized "current" Node identified by the persistent_id
  def perform
    log.update_attributes(:status => 'PROCESSING')
    # write the tmp file to local file store for processing
    node.generate_tmp_file 
    type = Bindery::Spreadsheet.detect_type(node)
    spreadsheet = type.new(node.local_file_pathname)
    if spreadsheet.sheets.count == node.worksheets.count
      # TODO: allow workers to force bindery to decompose worksheets again.
      # if log.attributes(:force) == true
      #   node.worksheets.each {|ws| ws.delete }
      #   ingest_all_worksheets(node, spreadsheet)
      # else
        #logger.warn("Spreadsheet in Node #{node.id} has already been decomposed.  To force re-run, set log.attributes(:force) to true" )
        logger.warn("Spreadsheet in Node #{node.id} has already been decomposed. Refusing to decompose again." )
      # end
    else
      ingest_all_worksheets(node, spreadsheet)
    end

    node.save #Saves associated worksheets
  end
  
  def ingest_all_worksheets(node, spreadsheet)
    spreadsheet.sheets.each_with_index do |worksheet, index|
      #logger.warn("Ingesting worksheet #{index} from Node #{node.id}." )
      ingest_worksheet(spreadsheet, worksheet, node, index)
    end
  end

  def ingest_worksheet(spreadsheet, worksheet, file, index)
    # Skip processing if the worksheet is empty (no rows)
    unless spreadsheet.first_row(worksheet).nil? || spreadsheet.last_row(worksheet).nil?
      sheet = Worksheet.create(:name=>worksheet, :order=>index)
      spreadsheet.first_row(worksheet).upto(spreadsheet.last_row(worksheet)) do |row_idx|
        #logger.warn("Ingesting row #{row_idx} of #{spreadsheet.last_row(worksheet)} from worksheet #{index} in Node #{node.id}." )
        ingest_row(spreadsheet, worksheet, sheet, row_idx)
      end
      sheet.save #Saves associated rows
      file.worksheets << sheet
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
    row = SpreadsheetRow.create(:row_number => row_idx, :job_log_item => @log, :values => stored_row)
    update_progress(spreadsheet, worksheet, row_idx)
    sheet.rows << row
  end

  def update_progress(spreadsheet, worksheet, row_idx)
    @total_rows ||= calculate_total_rows(spreadsheet)
    @cumulative_rows ||= 0
    @cumulative_rows += 1
    percent_done = (@cumulative_rows.to_f/@total_rows.to_f * 100.0).round(2)
    log.update_attributes(:message=>"#{percent_done}%")
  end

  def calculate_total_rows(spreadsheet)
    total = 0
    spreadsheet.sheets.each do |worksheet|
      worksheet_rows = spreadsheet.last_row(worksheet)
      total += worksheet_rows unless worksheet_rows.nil?
    end
    return total
  end

  def enqueue
    log.update_attributes(:status => 'ENQUEUE', data: node.id)
    Carrot.queue("decompose_spreadsheet").publish(log.id)
  end


  def success
    log.update_attributes(:status =>'SUCCESS', :message=>'') ### clear message that may have been from a previous failure.
  end

  def error(exception)
    log.status = 'ERROR'
    progress = "After processing #{log.message} of the spreadsheet, \n" unless log.message.empty?
    log.message = "#{progress} #{exception.message} (#{exception.class})" + exception.backtrace.join("\n")
    log.save!
  end

  def failure
    log.update_attributes(:status => 'FAILURE')
  end
  
  def node
    @node ||= Bindery::Spreadsheet.find_by_identifier(node_id)
  end
  
  def node=(new_node)
    @node = new_node
  end


end
