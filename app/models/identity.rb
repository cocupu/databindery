class Identity < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :login_credential
  has_many :pools, :foreign_key=>'owner_id', :dependent => :destroy

  after_create :create_pool

  def create_pool
    Pool.create!(:owner=>self)
  end

end
