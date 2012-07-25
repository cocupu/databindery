class CreateJobLogItems < ActiveRecord::Migration
  def change
    create_table :job_log_items do |t|
      t.string :status
      t.string :name
      t.string :message
      t.string :data
      t.integer :parent_id
      t.string :type  #For single table inheritance
 
      t.timestamps
    end
  end
end
