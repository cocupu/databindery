class Exhibit
  include Mongoid::Document
  field :title
  field :facets, type: Array
end
