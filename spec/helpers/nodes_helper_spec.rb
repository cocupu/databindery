require 'spec_helper'

describe NodesHelper do

  before do
    @field = {"name"=>"Description", "type"=>"Text Field", "uri"=>"dc:description", "code"=>"description"}
  end

  it "should draw field without default" do
    draw_field(@field).should == "<div class=\"control-group\"><label for=\"node_data_description\">Description</label><input id=\"node_data_description\" name=\"node[data][description]\" type=\"text\" /></div>"
  end
  it "should draw field with default" do
    draw_field(@field, "My Entry").should == "<div class=\"control-group\"><label for=\"node_data_description\">Description</label><input id=\"node_data_description\" name=\"node[data][description]\" type=\"text\" value=\"My Entry\" /></div>"
  end
end
