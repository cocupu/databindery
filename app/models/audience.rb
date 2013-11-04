class Audience < ActiveRecord::Base
  belongs_to :audience_category
  has_many :search_filters
  has_and_belongs_to_many :members, class_name: "Identity"#, inverse_of: :audiences
  attr_accessible :description, :name, :order, :pool_id
end
