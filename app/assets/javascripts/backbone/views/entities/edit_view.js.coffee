Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.EditView extends Backbone.View
  template : JST["backbone/templates/entities/edit"]

  events :
    "submit #edit-entity" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (entity) =>
        @model = entity
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
