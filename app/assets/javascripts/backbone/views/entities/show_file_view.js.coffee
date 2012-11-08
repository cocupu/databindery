Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowFileView extends Backbone.View
  template: JST["backbone/templates/entities/showFile"]


  render: ->
    dict = @model.toJSON()
    dict.title = @model.title()
    dict.url = @model.url()
    dict.content_type = @model.get('data')['content-type']
    $(@el).html(@template(dict))
    return this


