class Cocupu.Models.Pool extends Backbone.Model
  url: ->
    base = '/' + window.router.identity 
    base += '/' + @id if @id
    base

class Cocupu.Collections.PoolsCollection extends Backbone.Collection
  model: Cocupu.Models.Pool
  url: '/pools'
