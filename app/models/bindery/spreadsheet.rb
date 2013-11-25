### Non-namespaced version is used by roo
class Bindery::Spreadsheet < Node
  include FileEntity
  has_many :worksheets 

  def self.detect_type(node)
    case node.mime_type
    when "application/vnd.ms-excel"
      Roo::Excel
    when "application/vnd.oasis.opendocument.spreadsheet"
      Roo::OpenOffice
    else
      raise "UnknownType: #{chattel.attachment_content_type}"
    end
  end

  # Returns the node (version) where the latest file binding was set
  def self.version_with_latest_file_binding(persistent_id)
    node = self.versions(persistent_id).where(binding: self.latest_version(persistent_id).binding).select("created_at, binding, id, persistent_id").last
    return  Bindery::Spreadsheet.find_by_identifier(node.id)
  end

  # Returns the node (version) where the current node's file binding was set
  def version_with_current_file_binding
    node = self.versions.where(binding: self.binding).select("created_at, binding, id, persistent_id").last
    return  Bindery::Spreadsheet.find_by_identifier(node.id)
  end


end
