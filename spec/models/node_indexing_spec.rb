require 'spec_helper'

describe Node do
  let(:identity) { FactoryGirl.create :identity }
  let(:pool){ FactoryGirl.create :pool, :owner=>identity }
  let(:first_name_field) { FactoryGirl.create :first_name_field }
  let(:last_name_field) { FactoryGirl.create :last_name_field }
  let(:title_field) { FactoryGirl.create :title_field }

  let(:model) do
    FactoryGirl.create(:model,
                       fields: [first_name_field, last_name_field, title_field],
                       label_field: last_name_field, associations_attributes: [{name: 'authors', references: ref.id}])
  end
  let(:ref) do
    FactoryGirl.create(:model,
                       fields: [first_name_field, last_name_field, title_field],
                       label_field: last_name_field)
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

  describe "solr_attributes" do
    it "should return the part of the solr document that is just the model attributes" do
      subject.data = {first_name_field.id.to_s=>'Nina', last_name_field.id.to_s=>'Simone', title_field.id.to_s=>'Ms.'}
      expect(subject.solr_attributes).to eq({"first_name_ssi"=>"Nina", "first_name_sim"=>"Nina", "last_name_ssi"=>"Simone", "last_name_sim"=>"Simone", "title_tesim"=>"Ms.", "title_sim"=>"Ms."})
    end
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
      subject.data = {'f1'=>'good', first_name_field.id.to_s => 'Heathcliff', last_name_field.id.to_s => 'Huxtable', title_field.id.to_s=>'Dr.'}
    end

    it "should produce a solr document with correct field names, skipping fields that are not defined in the model" do
      # f1 is not defined as a field on the model, so it's not indexed.
      subject.to_solr.should == {'id'=>subject.persistent_id, 'version'=>subject.id, 'model_name' =>subject.model.name, 'pool' => pool.id, 'format'=>'Node', 'model'=>subject.model.id, 'title'=>'Huxtable', 'first_name_ssi'=>'Heathcliff', 'first_name_sim'=>'Heathcliff', 'last_name_ssi'=>'Huxtable', 'last_name_sim'=>'Huxtable', 'title_tesim' => 'Dr.', 'title_sim' => 'Dr.'}
    end
  end

  describe "with associations" do
    let(:full_name_field) {Field.create("name"=>"Name", "type"=>"TextField", "uri"=>"dc:description", "code"=>"full_name")}
    let(:book_title_field) {Field.create("code" => "book_title", "name"=>"Book title")}

    before do
      @author_model = FactoryGirl.create(:model, name: 'Author', label_field: full_name_field,
                                         fields: [full_name_field],
                                         owner: identity)
      @author1 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Agatha Christie'})
      @author2 = FactoryGirl.create(:node, model: @author_model, pool: pool, data: {full_name_field.id.to_s => 'Raymond Chandler'})
      @contributing_authors_association = OrderedListAssociation.create(:name=>'Contributing Authors', :code=>'contributing_authors', :references=>@author_model.id)
      subject.model = FactoryGirl.create(:model, name: 'Book', label_field: book_title_field, owner: identity,
                                         fields: [book_title_field],
                                         associations: [@contributing_authors_association])
      subject.data = {book_title_field.id.to_s=>'How to write mysteries'}
      subject.associations[@contributing_authors_association.id.to_s] = [@author1.persistent_id, @author2.persistent_id]
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
