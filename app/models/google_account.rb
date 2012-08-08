class GoogleAccount < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :owner, :class_name=>'Identity'
end
