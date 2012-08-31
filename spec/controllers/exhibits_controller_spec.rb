require 'spec_helper'

describe ExhibitsController do
  it "should route" do
    exhibits_path.should == '/exhibits'
  end

  before do
    @login = FactoryGirl.create :login
    pool = FactoryGirl.create :pool, :owner=>@login.identities.first
    @exhibit = FactoryGirl.create(:exhibit, pool: pool)
  end

  describe "when signed in" do
    before do
      sign_in @login
    end
    describe "index" do
      it "should be success" do
        get :index
        response.should be_successful
        assigns[:exhibits].should ==[@exhibit]
      end
    end

    describe "new" do
      it "should be success" do
        get :new
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
      end
    end

    describe "create" do
      it "should be success" do
        post :create, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }
        response.should redirect_to exhibit_path(assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
      end
    end

    describe "edit" do
      it "should be success" do
        get :edit, :id =>@exhibit.id
        response.should be_successful
        assigns[:exhibit].should be_kind_of Exhibit
      end
    end

    describe "update" do
      it "should be success" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }
        response.should redirect_to exhibit_path(assigns[:exhibit])
        assigns[:exhibit].facets.should == ['looketh', 'overmany', 'thither']
      end
    end

    describe "show" do
      before do
        ## Clear out old results so we start from scratch
        raw_results = Cocupu.solr.get 'select', :params => {:q => '{!lucene}model:"Mods and Rockers"', :fl=>'id', :qt=>'document', :qf=>'model', :rows=>100}
        Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
        raw_results = Cocupu.solr.get 'select', :params => {:q => 'bazaar', :fl=>'id', :qf=>'field_good_s'}
        Cocupu.solr.delete_by_id raw_results["response"]["docs"].map{ |d| d["id"]}
        Cocupu.solr.commit
        @model = Model.create!(:name=>"Mods and Rockers", owner: Identity.create!)
        @model.fields = [{code: 'f1', name: 'Field good'}]
        @model.save

        @instance = Node.new(data: {'f1' => 'bazaar'})
        @instance.model = @model
        @instance.pool = @exhibit.pool 
        @instance.save!
        @instance2 = Node.new(data: {'f1' => 'bazaar'})
        @instance2.model = @model
        @instance2.pool = FactoryGirl.create :pool
        @instance2.save!

      end
      it "should be success" do
        get :show, :id=>@exhibit.id, :q=>'bazaar'
        assigns[:total].should == 1
        assigns[:results].should_not be_nil
        assigns[:exhibit].should == @exhibit
        assigns[:facet_fields].should == {"name_s"=>[], "model_name"=>["Mods and Rockers", 1]}
        response.should be_successful
      end
    end
  end

  describe "when not signed in" do
    describe "index" do
      it "should be unauthorized" do
        get :index
        response.should redirect_to root_path
      end
    end

    describe "new" do
      it "should be unauthorized" do
        get :new
        response.should redirect_to root_path
      end
    end

    describe "create" do
      it "should be unauthorized" do
        post :create, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }
        response.should redirect_to root_path
      end
    end

    describe "edit" do
      it "should be unauthorized" do
        get :edit, :id =>@exhibit.id
        response.should redirect_to root_path
      end
    end

    describe "update" do
      it "should be unauthorized" do
        put :update, :id=>@exhibit.id, :exhibit=> {:title => 'Foresooth', :facets=>'looketh, overmany, thither' }
        response.should redirect_to root_path
      end
    end

    describe "show" do
      it "should be unauthorized" do
        get :show, :id=>@exhibit.id, :q=>'bazaar'
        response.should redirect_to root_path
      end
    end
  end


end
