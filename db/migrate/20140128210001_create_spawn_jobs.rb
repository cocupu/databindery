class CreateSpawnJobs < ActiveRecord::Migration
  def change
    create_table :spawn_jobs do |t|
      t.text :reification_job_ids
      t.references :mapping_template, index: true
      t.references :node, index: true
      t.references :pool, index: true

      t.timestamps
    end
  end
end
