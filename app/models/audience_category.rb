class AudienceCategory < ActiveRecord::Base
  has_many :audiences, :order => "position ASC, created_at ASC"
  belongs_to :pool

  attr_accessible :description, :name, :audiences_attributes
  accepts_nested_attributes_for :audiences, allow_destroy: true

  def audiences_for_identity(identity)
    identity_audiences = []
    audiences.each do |audience|
      if audience.member_ids.include?(identity.id)
        identity_audiences << audience
      end
    end
    return identity_audiences
  end

  def as_json(opts=nil)
    json = super(opts)
    json["audiences"] = self.audiences.order.as_json
    return json
  end
end
