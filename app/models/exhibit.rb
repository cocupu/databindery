class Exhibit < ActiveRecord::Base
  belongs_to :pool
  validates :pool, presence: true
  serialize :facets
end
