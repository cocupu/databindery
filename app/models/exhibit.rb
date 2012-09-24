class Exhibit < ActiveRecord::Base
  belongs_to :pool
  validates :pool, presence: true
  serialize :facets

  after_initialize :init
  def init
    self.facets ||= []
  end
end
