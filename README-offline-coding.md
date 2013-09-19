
``` ruby
identity = Identity.find_by_short_name("matt")
chattel = Chattel.create(owner: identity)
# chattel.attach(File.new(Rails.root + 'spec/fixtures/images/rails.png').read, 'image/png', 'spec/fixtures/images/rails.png')
chattel.attach(File.new(Rails.root + 'spec/fixtures/dechen_rangdrol_archives_database.xls').read, 'application/vnd.ms-excel', 'spec/fixtures/dechen_rangdrol_archives_database.xls')

decompose_log = JobLogItem.new(:status=>"READY", :name=>"DecomposeSpreadsheetJob", :data=>chattel.id)
@job = DecomposeSpreadsheetJob.new(chattel.id, decompose_log)
@job.node = chattel
@job.enqueue #start the logger
# Carrot.queue("decompose_spreadsheet").publish(decompose_log.id)
<!-- @job.perform -->

worksheet = Bindery::Spreadsheet.find(chattel.id).worksheets.first 

```


```
birgit = Identity.find_by_short_name("birgitscott")
matt = Identity.find_by_short_name("matt_zumwalt")
pool = birgit.pools.last
AccessControl.create!(identity: matt, pool: pool, access: 'EDIT')
```