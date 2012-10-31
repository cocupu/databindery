module CatalogHelper

  # Pass in an RSolr::Response (or duck-typed similar) object, 
  # it translates to a Kaminari-paginatable
  # object, with the keys Kaminari views expect. 
  def paginate_params(response)
    per_page = response["docs"].per_page
    per_page = 1 if per_page < 1
    current_page = response["docs"].current_page
    total_pages = response["docs"].total_pages
    Struct.new(:current_page, :num_pages, :limit_value).new(current_page, total_pages, per_page)
  end 

end
