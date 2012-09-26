class Cocupu.Models.Pool extends Backbone.Model
  url: ->
    base = '/' + window.router.identity 
    base += '/' + @id if @id
    base

  initialize: (attributes) ->
     this.id = attributes['short_name'] if attributes

class Cocupu.Collections.PoolsCollection extends Backbone.Collection
  model: Cocupu.Models.Pool
  url: '/pools'
