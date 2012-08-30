class Cocupu.Models.Pool extends Backbone.Model
  urlRoot : '/pools'

class Cocupu.Collections.PoolsCollection extends Backbone.Collection
  model: Cocupu.Models.Pool
  url: '/pools'
