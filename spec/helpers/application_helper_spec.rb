require 'spec_helper'

describe ApplicationHelper do
  before do
    @exhibit = Exhibit.create
    assign :exhibit, @exhibit
    params[:q] = 'term'
  end
  
  after do
    @exhibit.destroy
  end

  it "should render_facet_list" do
    out = helper.render_facet_list('name_s', ['Aluminium', '7'])
    out.should == "<ul><li><a href=\"/exhibits/#{@exhibit.id}?f%5Bname_s%5D=Aluminium&amp;q=term\" title=\"Aluminium\">Aluminium (7)</a></li></ul>"
    
  end

  it "should render_facet_link" do
    out = helper.render_facet_link('name_s', 'Aluminium', '7')
    out.should == "<a href=\"/exhibits/#{@exhibit.id}?f%5Bname_s%5D=Aluminium&amp;q=term\" title=\"Aluminium\">Aluminium (7)</a>"
    
  end

  it "should render_selected_facet" do
    out = helper.render_selected_facet('name_s', 'Aluminium', '7')
    out.should == "Aluminium (7) <a href=\"/exhibits/#{@exhibit.id}?&amp;q=term\" class=\"btn small\" title=\"Remove facet\">remove</a>"
    
  end
end
