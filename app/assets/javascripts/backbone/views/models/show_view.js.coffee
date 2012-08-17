Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.ShowView extends Backbone.View
  template: JST["backbone/templates/models/show"]

  render: ->
    dict = @model.toJSON()
    $(@el).html(@template(dict))
    return this
