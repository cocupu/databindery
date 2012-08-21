module NodesHelper
  def draw_field(field, default=nil)
    case field["type"]
    when "text"
      draw_text_field(field, default)
    end
  end
  
  private

  def draw_text_field(field, default)
    content_tag(:div, :class=> 'control-group') do
      label_tag("node[data][#{field["code"]}]", field["name"]) + 
      text_field_tag("node[data][#{field["code"]}]", default)
    end
  end
end
