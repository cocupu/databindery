Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowView extends Backbone.View
  template: JST["backbone/templates/entities/show"]

  render: ->
    dict = @model.toJSON()
    dict.title = @model.title()
    dict.model = @model.model().toJSON()
    $(@el).html(@template(dict))
    return this
