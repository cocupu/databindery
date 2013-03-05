module NodesHelper
  def draw_field(field, default=nil)
    case field["type"]
    when "text" 
      draw_text_field(field, default)
    when "date"
      draw_date_field(field, default)
    else
      draw_text_field(field, default)
    end
  end
  
  def link_to_node(node)
    link_to node.title, identity_pool_solr_document_path(@identity, @pool, node)
  end
  
  private

  def draw_text_field(field, default)
    content_tag(:div, :class=> 'control-group') do
      label_tag("node[data][#{field["code"]}]", field["name"]) + 
      text_field_tag("node[data][#{field["code"]}]", default)
    end
  end
  
  def draw_date_field(field, default)
    content_tag(:div, :class=> 'control-group') do
      label_tag("node[data][#{field["code"]}]", field["name"]) + 
      content_tag(:input, "", {:name=>"node[data][#{field["code"]}]", :type=>"date", :class=> 'control-group'})
    end
  end
end
