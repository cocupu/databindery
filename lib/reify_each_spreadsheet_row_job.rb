## A delayed job that enqueues one child job for each row in the spreadsheet.
class ReifyEachSpreadsheetRowJob < Struct.new(:log)

  def enqueue
    log.update_attributes(:status => 'ENQUEUE')
  end

  def perform
    logger.debug "Reify data: #{log.data}"
    row = SpreadsheetRow.find(log.data[:id])
    template = MappingTemplate.find(log.data[:template_id])
    pool = Pool.find(log.data[:pool_id])
    log.update_attributes(:status => 'PROCESSING')
    template.model_mappings.each do |model_tmpl|
      model = Model.find(model_tmpl[:model_id])
      vals = {}
      model_tmpl[:field_mappings].each do |map|
        next unless map[:field]
        if letter?(map[:source])
          field_index = map[:source].ord - 65
        else
          field_index = map[:source]
        end
        vals[map[:field]] = row.values[field_index]
      end
      n = Node.new(:data=>vals)
      n.spawned_from_datum = row
      n.model = model
      n.pool = pool 
      n.save!
    end
  end

  def letter?(character)
    character =~ /[A-Za-z]/
  end

  def success
    log.update_attributes(:status => 'SUCCESS')
  end

  def error(exception)
    log.status = 'ERROR'
    log.message = "#{exception.message} (#{exception.class})" + exception.backtrace.join("\n")
    log.save!
  end

  def failure
    log.update_attributes(:status => 'FAILURE')
  end
end
