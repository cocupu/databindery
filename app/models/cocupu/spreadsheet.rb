### Non-namespaced version is used by roo
class Cocupu::Spreadsheet < Chattel
  many :worksheets

  def self.detect_type(chattel)
    case chattel.attachment_content_type
    when "application/vnd.ms-excel"
      Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      Openoffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
  end


end
