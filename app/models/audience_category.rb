class AudienceCategory < ActiveRecord::Base
  has_many :audiences, :order => "position ASC, created_at ASC"
  belongs_to :pool

  attr_accessible :description, :name, :audiences_attributes
  accepts_nested_attributes_for :audiences, allow_destroy: true

  def as_json(opts=nil)
    json = super(opts)
    json["audiences"] = self.audiences.order.as_json
    return json
  end
end
