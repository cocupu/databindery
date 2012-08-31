Cocupu.Views.Pools ||= {}

class Cocupu.Views.Pools.IndexView extends Backbone.View
  template: JST["backbone/templates/pools/index"]

  addAll: () =>
    @collection.each(@addOne)

  addOne: (model) =>
    view = new Cocupu.Views.Pools.PoolView({model : model})
    this.$('ul').append(view.render().el)

  render: =>
    $(@el).html(@template())
    @addAll()

    return this

