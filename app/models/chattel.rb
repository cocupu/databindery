class Chattel
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :attachment

end
