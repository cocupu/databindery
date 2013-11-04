class AudienceCategory < ActiveRecord::Base
  has_many :audiences, :order => "position ASC, created_at ASC"
  belongs_to :pool
  attr_accessible :description, :name
end
