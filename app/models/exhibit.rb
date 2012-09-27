class Exhibit < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :pool
  validates :pool, presence: true
  serialize :facets
  serialize :index_fields

  after_initialize :init

  def init
    self.facets ||= []
    self.index_fields ||= []
  end
end
