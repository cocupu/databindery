Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.EntityView extends Backbone.View
  template: JST["backbone/templates/entities/entity"]

  events:
    "click .destroy" : "destroy"

  tagName: "li"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    dict = @model.toJSON()
    dict.title = @model.title()
    dict.model = @model.model().toJSON()
    $(@el).attr('id', 'node_'+@model.id).addClass('node').html(@template(dict))
    return this
