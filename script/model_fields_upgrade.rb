Model.all.each do |m|
  errors = []
  YAML.load(m[:fields]).each do |field_hash|
    field_hash = ActionController::Parameters.new(field_hash)
    case field_hash["type"]
      when "text"
        field_hash["type"] = "TextField"
      when "string"
        field_hash["type"] = "TextField"
      when "integer"
        field_hash["type"] = "InegerField"
      when "date"
        field_hash["type"] = "DateField"
      when "textarea"
        field_hash["type"] = "TextArea"
      else
        # do nothing
    end
    begin
      field = Field.create(field_hash.permit(:id, :name, :type, :code, :uri, :multivalue))
    rescue
      errors << {model: m.id, field_hash: field_hash}
    end
    m.fields << field
    m.save
  end

  if errors.empty?
    puts "Finished with no errors."
  else
    puts "Errors:"
    puts errors
  end

end