class Pool < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true
  has_many :exhibits, :dependent => :destroy
  has_many :nodes, :dependent => :destroy
end
