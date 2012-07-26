class Pool < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true
end
