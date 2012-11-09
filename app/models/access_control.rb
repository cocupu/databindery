class AccessControl < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :identity
  belongs_to :pool
  validates :identity, :presence=>true
  validates :pool, :presence=>true
  validates :access, :presence=>true, :inclusion => { :in => ['READ', 'EDIT'] }
end
