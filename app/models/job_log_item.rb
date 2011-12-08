class JobLogItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, index: true
  field :name
  field :message
  belongs_to :parent, :class_name=>"JobLogItem", index: true
  has_many :children, :class_name=>"JobLogItem", :foreign_key => "parent_id"
  
  after_update :alert_parent_of_status_change

  ## if status is changed, alert the parent
  def alert_parent_of_status_change
    needs_alert = self.changes["status"].present? && parent
    parent.member_finished if needs_alert
  end
  

end
