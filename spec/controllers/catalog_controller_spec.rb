require 'spec_helper'

describe CatalogController do
  describe "routes" do
    it "should route" do
      identity_exhibit_solr_document_path('matt', '88', '9990101-231-1223').should == '/matt/exhibits/88/9990101-231-1223'
    end
  end

  before do
    @identity = FactoryGirl.create :identity
    @pool = FactoryGirl.create :pool, :owner=>@identity
    @exhibit = FactoryGirl.build(:exhibit, pool: @pool)
    @exhibit.facets = ['f2']
    @exhibit.index_fields = ['f1', 'f2']
    @exhibit.save!

    @model1 = FactoryGirl.create(:model, :name=>"Mods and Rockers", :pool=>@exhibit.pool)

    @model1.fields = [{code: 'f1', name: 'Field good'}.with_indifferent_access, {code: 'f2', name: "Another one"}.with_indifferent_access]
    @model1.save!
    @model2 = FactoryGirl.create(:model, :pool=>@exhibit.pool)
    @model2.fields = [{code: 'style', name: 'Style'}.with_indifferent_access, {code: 'label', name: "Label"}.with_indifferent_access, {code: 'f2', name: "Another one"}.with_indifferent_access]

    #TODO ensure that code is unique for all fields in a pool, so that Author.name is separate from Book.name
    @model2.save!
    ## Clear out old results so we start from scratch
    raw_results = Bindery.solr.get 'select', :params => {:q => '{!lucene}model_name:"Mods and Rockers"', :fl=>'id', :qt=>'document', :qf=>'model', :rows=>100}
    Bindery.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
    raw_results = Bindery.solr.get 'select', :params => {:q => 'bazaar', :fl=>'id', :qf=>'field_good_s'}
    Bindery.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
    Bindery.solr.commit

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

    describe "index" do
      it "should apply filters and facets from exhibit" do
        exhibit_with_filters = FactoryGirl.build(:exhibit, pool: @pool, filters_attributes: [field_name:"subject", operator:"+", values:["test", "barf"]])
        exhibit_with_filters.save!
        get :index, :exhibit_id=>exhibit_with_filters.id, :q=>'bazaar', :identity_id=>@identity.short_name
        #user_params = {:exhibit_id=>exhibit_with_filters.id, :q=>'bazaar', :identity_id=>@identity.short_name}
        subject.solr_search_params[:fq].should include('subject_s:"test" OR subject_s:"barf"')
      end
    end
    describe "show" do
      it "should be success" do
        get :index, :exhibit_id=>@exhibit.id, :q=>'bazaar', :identity_id=>@identity.short_name
        assigns[:document_list].size.should == 1
        assigns[:exhibit].should == @exhibit
        assigns[:response]['facet_counts']['facet_fields'].should == {"f2_facet"=>["Bizarre", 1]}
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
        assigns[:response]['facet_counts']['facet_fields'].should == {"f2_facet"=>["Bizarre", 1]}
        response.should be_successful
      end
    end
  end
end
