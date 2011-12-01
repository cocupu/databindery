require 'spec_helper'

describe MappingTemplatesController do

  describe "create with a single model" do
    it "should create" do
      post :create, :chattel_id=>7, :mapping_template=>{"row_start"=>"2", :models=>{'0'=>{:name=>"Talk", :mapping=>{'0'=>{:label=>"File Name", :source=>"A"}, '1'=>{:label=>"Title", :source=>"C"},'2'=>{:label=>"", :source=>""}}}}}
      response.should be_success
      assigns[:mapping_template].row_start.should == 2
      assigns[:mapping_template].models.should == [{"name"=>'Talk', "mapping"=>[{"label"=>'File Name', "source"=>'A'}, {"label"=>'Title', "source"=>'C'}]}]
    
    end
  end

end
