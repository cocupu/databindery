module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_previous_document(previous_document)
    path = identity_exhibit_solr_document_path(@identity, @exhibit, previous_document) if previous_document
    link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), path, :class => "previous", :rel => 'prev', :'data-counter' => session[:search][:counter].to_i - 1 do
      content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
    end
  end

  def link_to_next_document(next_document)
    path = identity_exhibit_solr_document_path(@identity, @exhibit, next_document) if next_document
    link_to_unless next_document.nil?, raw(t('views.pagination.next')), path, :class => "next", :rel => 'next', :'data-counter' => session[:search][:counter].to_i + 1 do
      content_tag :span, raw(t('views.pagination.next')), :class => 'next'
    end
  end 

end
