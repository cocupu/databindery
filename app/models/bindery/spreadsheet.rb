### Non-namespaced version is used by roo
class Bindery::Spreadsheet < Node
  include FileEntity
  has_many :worksheets 

  def self.detect_type(node)
    case node.mime_type
    when "application/vnd.ms-excel"
      Roo::Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      Roo::Openoffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
  end


end
