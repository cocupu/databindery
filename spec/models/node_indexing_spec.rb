require 'spec_helper'

describe Node do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool){ FactoryGirl.create :pool, :owner=>identity }
  let(:model) do
    FactoryGirl.create(:model,
                       fields_attributes: [{'code' => 'first_name', 'multivalue' => false}, {'code' => 'last_name'}, {'code' => 'title', 'multivalue' => true}],
                       label: 'last_name', associations_attributes: [{name: 'authors', references: ref.id}])
  end
  let(:ref) do
    FactoryGirl.create(:model,
                       fields_attributes: [{'code' => 'first_name'}, {'code' => 'last_name'}, {'code' => 'title'}],
                       label: 'last_name')
  end

  before do
    subject.model = model
  end

  it "should index itself when it's saved" do
    Bindery.should_receive :index
    Bindery.solr.should_receive :commit
    subject.pool = pool
    subject.model = FactoryGirl.create(:model)
    subject.save!
  end

  describe "solr_name" do
    it "should remove whitespaces" do
      Node.solr_name("one two\t\tthree").should == "one_two_three_ssi"
    end
    it "should use the type" do
      Node.solr_name("one two", :type=>'facet').should == "one_two_sim"
    end
    it "should use the prefix" do
      Node.solr_name("first name", :prefix=>'related_object__', :type=>'facet').should == "related_object__first_name_sim"
    end
    it "should handle special terms" do
      Node.solr_name("model_name").should == "model_name"
      Node.solr_name("model").should == "model"

    end
  end

  describe "with data" do
    before do
      subject.pool = pool
      subject.data = {'f1'=>'good', 'first_name' => 'Heathcliff', 'last_name' => 'Huxtable', 'title'=>'Dr.'}
    end

    it "should produce a solr document with correct field names, skipping fields that are not defined in the model" do
      # f1 is not defined as a field on the model, so it's not indexed.
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => pool.id, 'format'=>'Node', 'model'=>subject.model.id, 'title'=>'Huxtable', 'first_name_ssi'=>'Heathcliff', 'first_name_sim'=>'Heathcliff', 'last_name_ssi'=>'Huxtable', 'last_name_sim'=>'Huxtable', 'title_tesim' => 'Dr.', 'title_sim' => 'Dr.'}
    end
  end

  describe "with associations" do
    before do
      @author_model = FactoryGirl.create(:model, name: 'Author', label: 'full_name',
                                         fields_attributes: [{"name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"full_name"}],
                                         owner: identity)
      @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Agatha Christie'})
      @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {'full_name' => 'Raymond Chandler'})

      subject.model = FactoryGirl.create(:model, name: 'Book', label: 'book_title', owner: identity,
                                         fields_attributes: [{"code" => "book_title", "name"=>"Book title"}],
                                         associations_attributes: [{:name=>'Contributing Authors', :code=>'contributing_authors', :references=>@author_model.id}])
      subject.data = {'book_title'=>'How to write mysteries'}
      subject.associations['contributing_authors'] = [@author1.persistent_id, @author2.persistent_id]
      subject.pool = pool
      subject.save!
    end
    it "should index the properties of the child associations and add their persistent ids to an bindery__associations_facet field" do
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => pool.id,
                                 'format'=>'Node', 'model'=>subject.model.id,
                                 'contributing_authors_sim'=>['Agatha Christie', 'Raymond Chandler'],
                                 'contributing_authors_tesim'=>['Agatha Christie', 'Raymond Chandler'],
                                 'contributing_authors__full_name_tesim'=>['Agatha Christie', 'Raymond Chandler'],
                                 'contributing_authors__full_name_sim'=>['Agatha Christie', 'Raymond Chandler'],
                                 "book_title_sim" => "How to write mysteries",
                                 "book_title_ssi" => "How to write mysteries",
                                 "title" => "How to write mysteries",
                                 "bindery__associations_sim" => [@author1.persistent_id, @author2.persistent_id]
      }
    end
  end

end
