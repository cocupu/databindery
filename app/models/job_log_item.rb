class JobLogItem < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :parent, :class_name=>'JobLogItem'
  belongs_to :loggable_job, :polymorphic => true
  default_scope { order("updated_at desc") }

  serialize :data
  #attr_accessible :status, :data, :name
  has_many :children, :foreign_key =>'parent_id', :class_name=>"JobLogItem"
  
  after_update :alert_parent_of_status_change


  def count_children_with_status(values)
    children.where(:status => values).count
  end
  

  ## if status is changed, alert the parent
  def alert_parent_of_status_change
    needs_alert = self.status_changed? && parent
    parent.member_finished if needs_alert
  end
  

end
