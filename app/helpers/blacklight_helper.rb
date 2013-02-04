module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  def solr_document_path(doc)
    if params[:controller] == "catalog"
        identity_exhibit_solr_document_path(@identity, @exhibit, doc) if doc
    else
      identity_pool_solr_document_path(@identity, @pool, doc) if doc
    end
  end

end
