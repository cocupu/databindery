module ApplicationHelper

  APP_VERSION = "0.1"

  def add_child_link(name, association, index)
    link_to(name, "javascript:void(0)", :class => "btn add_child", :"data-association" => association, :"data-index" => index.to_s)
  end
  
  def facet_params
    params[:f] || {}
  end


  def render_facet_list(facet_field, facet_value, html_id)
    content_tag('ul', :id=>html_id, :class=>'accordion_body collapse') do
      if facet_params.has_key?(facet_field)
        content_tag('li') do
          arg = facet_value.shift(2)
          render_selected_facet(facet_field, facet_params[facet_field], arg[1] || 0)
        end
      else
        out = ""
        while facet_value.present? do
          arg = facet_value.shift(2)
          out << content_tag('li') do
            render_facet_link(facet_field, arg[0], arg[1])
          end
        end
        out.html_safe
      end
    end
  end

  def render_facet_link(facet_field, facet_value,  count)
    facet_params = params[:f] ? params[:f].dup : {}
    facet_params[facet_field] = facet_value
    link_to "#{truncate(facet_value)} (#{count})", identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit, :f=>facet_params, :q=>params[:q]), :title=>facet_value
  end

  def render_selected_facet(facet_field, facet_value,  count)
    facet_params = params[:f] ? params[:f].dup : {}
    facet_params.delete(facet_field)
    "#{facet_value} (#{count}) ".html_safe +
    link_to("remove", identity_pool_exhibit_path(@identity.short_name, @pool, @exhibit, :f=>facet_params, :q=>params[:q]), :title=>'Remove facet', :class=>'btn small')
  end

  

    # Equivalent to kaminari "paginate", but takes an RSolr::Response as first argument. 
  # Will convert it to something kaminari can deal with (using #paginate_params), and
  # then call kaminari paginate with that. Other arguments (options and block) same as
  # kaminari paginate, passed on through. 
  # will output HTML pagination controls. 
  def paginate_rsolr_response(response, options = {}, &block)
    per_page = response["docs"].per_page
    per_page = 1 if per_page < 1
    current_page = response["docs"].current_page
    paginate Kaminari.paginate_array(response['docs'], :total_count => response['docs'].total).page(current_page).per(per_page), options, &block
  end
  
  # Check whether the current controller matches any of the controller names provided as arguments
  # @example
  #   controller?("pools", "pool_searches") 
  def controller?(*controller)
    controller.include?(params[:controller])
  end
  
  # Check whether the current controller action matches any of the action names provided as arguments
  # @example
  #   action?("index", "show")
  def action?(*action)
    action.include?(params[:action])
  end
end
