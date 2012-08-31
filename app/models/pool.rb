class Pool < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :owner, class_name: "Identity"
  validates :owner, presence: true
  has_many :exhibits, :dependent => :destroy
  has_many :nodes, :dependent => :destroy
  has_many :models, :dependent => :destroy

  validates :short_name, :format=>{:with => /\A[\w-]+\Z/}, :uniqueness => true
  
  def short_name=(name)
    write_attribute :short_name, name.downcase
  end
end
