module Bindery::Identifiable
  
  def generate_uuid
    self.persistent_id= UUID.new.generate if !persistent_id
  end
end