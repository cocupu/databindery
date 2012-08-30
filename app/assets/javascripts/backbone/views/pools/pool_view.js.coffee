Cocupu.Views.Pools ||= {}

class Cocupu.Views.Pools.PoolView extends Backbone.View
  template: JST["backbone/templates/pools/pool"]

  tagName: 'li'

  render: ->
    dict = @model.toJSON()
    $(@el).html(@template(dict))
    return this

