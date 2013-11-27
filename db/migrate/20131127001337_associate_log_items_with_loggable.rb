class AssociateLogItemsWithLoggable < ActiveRecord::Migration
  def change
    change_table :job_log_items do |t|
      t.belongs_to :loggable_job, polymorphic: true
    end
    add_index :job_log_items, [:loggable_job_id, :loggable_job_type]
  end
end
