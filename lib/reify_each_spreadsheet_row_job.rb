## A delayed job that enqueues one child job for each row in the spreadsheet.
class ReifyEachSpreadsheetRowJob < Struct.new(:row, :input, :log)

  def enqueue
    log.update_attribute(:status, 'ENQUEUE')
  end

  def perform
    log.update_attribute(:status, 'PROCESSING')
    input[:template].models.each do |model_id, model_tmpl|
      model = Model.find(model_id)
      vals = {}
      model_tmpl[:field_mappings].each do |fm_source, field|
        field = model.fields['field']
        vals[field] = row.values[fm_source.ord - 65]
      end
      Node.create!(:model=>model, :data=>vals)
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
end
