module ApplicationHelper
  def add_child_link(name, association, index)
    link_to(name, "javascript:void(0)", :class => "add_child", :"data-association" => association, :"data-index" => index.to_s)
  end
  
  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    
    tag_name = options[:tag] || :div
    tag_id =  "#{association}_#{options[:index] || 0 }_fields_template"
    content_tag(tag_name, :id => tag_id, :style => "display: none") do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :locals => {options[:form_builder_local] => f})
      end
    end
  end

  def render_facet_link(facet_field, facet_value,  count)
    facet_params = params[:f] ? params[:f].dup : {}
    if facet_params.has_key?(facet_field)
      facet_params.delete(facet_field)
      "#{facet_value} (#{count})".html_safe +
      link_to("X", exhibit_path(@exhibit, :f=>facet_params, :q=>params[:q]), :title=>'Remove facet')
    else
      facet_params[facet_field] = facet_value
      link_to "#{truncate(facet_value)} (#{count})", exhibit_path(@exhibit, :f=>facet_params, :q=>params[:q]), :title=>facet_value
    end

  end
end
