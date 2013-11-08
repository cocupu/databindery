class SearchFilter < ActiveRecord::Base
  belongs_to :filterable, :polymorphic => true
  serialize :values, Array
  attr_accessible :field_name, :operator, :values


  def apply_solr_params(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    if values.length > 1 && operator == "+"
      solr_parameters[:fq] << values.map {|v| "#{Node.solr_name(field_name)}:\"#{v}\"" }.join(" OR ")
    else
      values.each do |v|
        solr_parameters[:fq] << "#{operator}#{Node.solr_name(field_name)}:\"#{v}\""
      end
    end



    solr_parameters
  end
end
