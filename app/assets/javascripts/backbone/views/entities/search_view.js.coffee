Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchView extends Backbone.View
  template : JST["backbone/templates/entities/search"]

  render : ->
    $(@el).addClass('searchPane').html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this

