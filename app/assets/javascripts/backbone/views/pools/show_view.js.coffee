Cocupu.Views.Pools ||= {}

class Cocupu.Views.Pools.ShowView extends Backbone.View
  template: JST["backbone/templates/pools/show"]

  render: =>
    $(@el).html(@template(@model.toJSON()))

    return this

