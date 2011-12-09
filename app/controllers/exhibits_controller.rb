class ExhibitsController < ApplicationController
  def index
    if params[:q]
      ## TODO constrain fields just to models in this pool/exhibit
      fields = Field.all.map {|f| f.solr_name }.uniq
      @raw_results = Cocupu.solr.get 'select', :params => {:q => params[:q], :qf=>fields.join(' ')}
      @total = @raw_results['response']["numFound"]
      @results = ModelInstance.find(@raw_results['response']["docs"].map{|d| d['id']})
    end
  end

end
