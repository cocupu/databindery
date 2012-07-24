class CreateChattel < ActiveRecord::Migration
  def change
    create_table :chattels do |t|
      t.string :attachment_content_type
      t.string :attachment_file_name
      t.string :attachment_extension
 
      t.timestamps
    end
  end
end
