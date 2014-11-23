


#  FIELDS
# fix_fields = []
# Model.all.each do |m|
#   if m[:fields].count != m.fields.count
#    fix_fields << m
#   end 
#   fix_fields.count
# end

to_process = Model.all
# to_process = field_failures.keys.map {|i| Model.find(i) }
field_failures = {}
to_process.each do |m|
  fields = m[:fields]
  fields.each_with_index do |f, index|
    f["type"] = convert_field_type(f["type"])
    f.delete("value")
    if f["multivalued"] == "on" || f["multivalued"] == true
      f["multivalue"] = true
    end
    f.delete("multivalued")
    if f.instance_of?(ActionController::Parameters)
      fields[index] = f.permit(:name, :type, :code, :uri, :multivalue).to_hash
    end
  end
  begin
      m.update_attributes(fields_attributes: fields)
  rescue
    field_failures[m.id] ||= []
    field_failures[m.id] << fields
  end
end

def convert_field_type(original_value)
  case original_value
  when "Text Field"
   'TextField' 
  when "text_field"
    'TextField'
  when "textfield"
    'TextField'
  when "string"
    'TextField'
  when "text"
   'TextArea'
  when "Text Area"
   'TextArea'
  when "text_area"
    'TextArea'
  when "textarea"
    'TextArea'
  when "integer"
    'IntegerField'
  when "Number"
    'IntegerField'
  when "Date"
    'DateField'
  when "date"
    'DateField'
  else
    original_value
  end
end


# Associations

to_fix = []
Model.all.each do |m|
  if m[:associations].count != m.associations.count
   to_fix << m
  end 
  to_fix.count
end

#to_fix = [5, 7, 23, 17, 26, 22, 33, 37, 34, 27, 55, 56, 58, 60, 46, 107, 25, 66, 72, 59, 73, 70, 76, 75, 92, 94, 96, 93, 98, 102, 97, 95, 103, 49] 

failures = {}
to_fix.each do |m|
  m.associations.destroy_all
  m[:associations].each do |assoc|
    assoc[:type] = "OrderedListAssociation"
    begin
      if assoc.instance_of?(ActionController::Parameters)
        m.associations.create(assoc.permit(:name, :type, :code, :uri, :references, :multivalue, :label))
      else
        m.associations.create(assoc)
      end
    rescue
      failures[m.id] ||= []
      failures[m.id] << assoc
    end
  end
end

# Not Associations: 
Field.where.not(type: OrderedListAssociation)
Field.where(type: nil)

Field.where('type != ?',OrderedListAssociation)

Field.where('type != ? OR type IS null',OrderedListAssociation)