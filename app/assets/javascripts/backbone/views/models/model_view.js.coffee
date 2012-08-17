Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.ModelView extends Backbone.View
  template: JST["backbone/templates/models/model"]

  events:
    "click .destroy" : "destroy"

  tagName: "li"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    dict = @model.toJSON()
    $(@el).attr('id', 'model_'+@model.id).addClass('model').html(@template(dict))
    return this
