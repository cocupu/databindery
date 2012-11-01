module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_previous_document(previous_document)
    link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), identity_exhibit_solr_document(@identity, @exhibit, previous_document), :class => "previous", :rel => 'prev', :'data-counter' => session[:search][:counter].to_i - 1 do
      content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
    end
  end

  def link_to_next_document(next_document)
    link_to_unless next_document.nil?, raw(t('views.pagination.next')), identity_exhibit_solr_document(@identity, @exhibit, next_document), :class => "next", :rel => 'next', :'data-counter' => session[:search][:counter].to_i + 1 do
      content_tag :span, raw(t('views.pagination.next')), :class => 'next'
    end
  end 

end
