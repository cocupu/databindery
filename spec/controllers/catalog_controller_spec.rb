require 'spec_helper'

describe CatalogController do

  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @exhibit = FactoryGirl.build(:exhibit, pool: @pool)
    @exhibit.facets = ['f2']
    @exhibit.save!
    @model1 = FactoryGirl.create(:model, :name=>"Mods and Rockers", :pool=>@exhibit.pool)

    @model1.fields = [{code: 'f1', name: 'Field good'}, {code: 'f2', name: "Another one"}]
    @model1.save!
    @model2 = FactoryGirl.create(:model, :pool=>@exhibit.pool)
    @model2.fields = [{code: 'style', name: 'Style'}, {code: 'label', name: "Label"}, {code: 'f2', name: "Another one"}]

    #TODO ensure that code is unique for all fields in a pool, so that Author.name is separate from Book.name
    @model2.save!
    ## Clear out old results so we start from scratch
    raw_results = Cocupu.solr.get 'select', :params => {:q => '{!lucene}model_name:"Mods and Rockers"', :fl=>'id', :qt=>'document', :qf=>'model', :rows=>100}
    Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
    raw_results = Cocupu.solr.get 'select', :params => {:q => 'bazaar', :fl=>'id', :qf=>'field_good_s'}
    Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
    Cocupu.solr.commit

    @instance = Node.new(data: {'f1' => 'bazaar'})
    @instance.model = @model1
    @instance.pool = @exhibit.pool 
    @instance.save!

    @instance.data['f2'] = 'Bizarre'
    @instance.save! #Create a new version of this, only one version should show in search results.

    @instance2 = Node.new(data: {'f1' => 'bazaar'})
    @instance2.model = @model1
    @instance2.pool = FactoryGirl.create :pool
    @instance2.save!

  end

  describe "when signed in" do

    before do
      sign_in @identity.login_credential
    end

    describe "show" do
      it "should be success" do
        get :index, :exhibit_id=>@exhibit.id, :q=>'bazaar', :identity_id=>@identity.short_name
        assigns[:document_list].size.should == 1
        assigns[:exhibit].should == @exhibit
       puts assigns[:response]['facet_counts']['facet_fields'].should == {"f2_facet"=>["Bizarre", 1], "model_name"=>["Mods and Rockers", 1]}
        response.should be_successful
      end
    end
  end
  describe "when not signed in" do
    describe "show" do
      it "should be successful" do
        get :index, :exhibit_id=>@exhibit.id, :q=>'bazaar', :identity_id=>@identity.short_name
        assigns[:document_list].size.should == 1
        assigns[:exhibit].should == @exhibit
        response.should be_successful
      end
    end
  end
end
