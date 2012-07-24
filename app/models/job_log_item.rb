class JobLogItem < ActiveRecord::Base
  belongs_to :parent, :class_name=>'JobLogItem'
  belongs_to :spreadsheet_row

  #TODO has_many
  def children= children
    children.each do |c|
      c.update_attribute(:parent_id, self.id)
    end
  end
  
  after_update :alert_parent_of_status_change


  def count_children_with_status(values)
    JobLogItem.where(:parent_id => self.id, :status => values).count
  end
  

  ## if status is changed, alert the parent
  def alert_parent_of_status_change
    needs_alert = self.previous_changes["status"].present? && parent
    parent.member_finished if needs_alert
  end
  

end
