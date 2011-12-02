## A delayed job that enqueues one child job for each row in the spreadsheet.
class ReifyEachSpreadsheetRowJob < Struct.new(:row, :input, :parent_id, :log)

  def enqueue(job)
    log.update_attribute(:status, 'ENQUEUE')
  end

  def perform
    log.update_attribute(:status, 'PROCESSING')
    input[:template].models.each do |model_tmpl|
      model = model_tmpl.referenced_model() #TODO pass pool so that each user can reuse same names
      vals = [] 
      model_tmpl.field_mappings.each do |fm|
        field = model.m_fields.where(label: fm.label).first
        vals << Property.new(:field=> field, :value=>row.values[fm.source.ord - 65])
      end
      ModelInstance.create!(:model=>model, :properties=>vals)
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
