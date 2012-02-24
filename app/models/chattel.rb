class Chattel
  include Ripple::Document
  # include Mongoid::Paperclip

  #has_mongoid_attached_file :attachment
  alias_method :id, :key

  def spreadsheet?
    ["application/vnd.ms-excel"].include? attachment_content_type
  end

end
