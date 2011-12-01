class Chattel
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :attachment

  def spreadsheet?
    ["application/vnd.ms-excel"].include? attachment_content_type
  end

end
