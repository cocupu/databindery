Steps for Spawning from a file

<pre>
@identity = Identity.find_by_short_name("matt_zumwalt")
@pool =  Pool.find_by_short_name("ktgr_audio")


# Attach Spreadsheet to a Chattel & Decompose it
ss_path = "/opt/cocupu/spec/fixtures/KTGR Archive Collection List Sample.xls"
ss_path = "/Users/matt/Develop/ruby/marpa-db-import/KTGR Archive Collection List Sample.xls"

@file  =File.new(ss_path) 
@chattel = Bindery::Spreadsheet.create(owner: @identity)
@chattel.attach(@file.read, 'application/vnd.ms-excel', File.basename(ss_path))
@chattel.save!
@job = DecomposeSpreadsheetJob.new(@chattel.id, JobLogItem.new)
@job.enqueue #start the logger
@job.perform
sheets = Bindery::Spreadsheet.find(@chattel.id).worksheets
sheets.count
sheets.first.rows.count

# Create MappingTemplate
Open http://bindery.cocupu.com/matt_zumwalt/ktgr_audio/mapping_templates/new?mapping_template[worksheet_id]=#{@chattel.id}
...
collection_model_id = 49
@template = MappingTemplate.new(row_start: 2, file_type:"Collection List", identity_id: @identity.id, pool_id: @pool.id)
@template.model_mappings = [{:field_mappings=>[{"source"=>"A", "label"=>""}, {"source"=>"B", "label"=>"Submitted By", "field"=>"submitted_by"}, {"source"=>"C", "label"=>"Collection Name", "field"=>"collection_name"}, {"source"=>"D", "label"=>"Media", "field"=>"media"}, {"source"=>"E", "label"=>"# of Media", "field"=>"#_of_media"}, {"source"=>"F", "label"=>"Collection Owner", "field"=>"collection_owner"}, {"source"=>"G", "label"=>"Collection Location", "field"=>"collection_location"}, {"source"=>"H", "label"=>"Program Title English", "field"=>"program_title_english"}, {"source"=>"I", "label"=>"Main Text Title Tibetan", "field"=>"main_text_title_tibetan"}, {"source"=>"J", "label"=>"Main Text Title English", "field"=>"main_text_title_english"}, {"source"=>"K", "label"=>"Program Location", "field"=>"program_location"}, {"source"=>"L", "label"=>"Date from", "field"=>"date_from"}, {"source"=>"M", "label"=>"Date to", "field"=>"date_to"}, {"source"=>"N", "label"=>"Teacher", "field"=>"teacher"}, {"source"=>"O", "label"=>"Restricted?", "field"=>"restricted?"}, {"source"=>"P", "label"=>"Original Recorded by", "field"=>"original_recorded_by"}, {"source"=>"Q", "label"=>"Copy or Original", "field"=>"copy_or_original"}, {"source"=>"R", "label"=>"Translation Languages", "field"=>"translation_languages"}, {"source"=>"S", "label"=>"Notes", "field"=>"notes"}, {"source"=>"T", "label"=>"Post-Digi Notes", "field"=>"post-digi_notes"}, {"source"=>"U", "label"=>"Post-production notes", "field"=>"post-production_notes"}], :name=>"Collection", :label=>"true", :model_id=>collection_model_id}]
@template.model_mappings.first[:field_mappings].each {|mm| mm = mm.with_indifferent_access}
@template.model_mappings.first[:field_mappings].each_with_index do |mm, index| 
  @template.model_mappings.first[:field_mappings][index] = mm.with_indifferent_access
end

@template.save

# Reify each Row
sheets.first.rows.each do |ss_row|
  ticket = JobLogItem.new(:data=>{:id=>ss_row.id, :template_id => @template.id, :pool_id => @pool.id})
  job = ReifyEachSpreadsheetRowJob.new(ticket)
  job.enqueue
  job.perform
end
</pre>