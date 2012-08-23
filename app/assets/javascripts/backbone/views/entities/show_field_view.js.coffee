Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowFieldView extends Backbone.View
  template: JST["backbone/templates/entities/showField"]


  render: ->
    dict = @model
    $(@el).html(@template(dict))
    return this

