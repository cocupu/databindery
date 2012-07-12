class ChangeSet < ActiveRecord::Base
  belongs_to :previous, :class_name=>"ChangeSet", :foreign_key => :parent_id
  belongs_to :pool
  
end
