## A delayed job that enqueues one child job for each row in the spreadsheet.
class ReifyEachSpreadsheetRowJob < Struct.new(:row, :template, :log)

  def enqueue
    log.update_attributes(:status => 'ENQUEUE')
  end

  def perform
    log.update_attributes(:status => 'PROCESSING')
    template.models.each do |model_id, model_tmpl|
      model = Model.find(model_id)
      vals = {}
      model_tmpl[:field_mappings].each do |fm_source, field|
        vals[field] = row.values[fm_source.ord - 65]
      end
      Node.create!(:model=>model, :data=>vals)
    end
  end

  def success(job)
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
