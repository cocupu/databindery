module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  def solr_document_path(doc)
        identity_exhibit_solr_document_path(@identity, @exhibit, doc) if doc
  end

end
