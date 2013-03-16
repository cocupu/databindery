Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowFieldView extends Backbone.View
  template: JST["backbone/templates/entities/showField"]


  render: ->
    dict = @model
    dict.type ||= "text"
    $(@el).html(@template(dict))
    return this

