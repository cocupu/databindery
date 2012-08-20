Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowView extends Backbone.View
  template: JST["backbone/templates/entities/show"]

  events: {
    "click .close": "close"
  }

  close: ->
    @remove()
    @unbind()
#    @model.unbind("change", @modelChanged)
    false

  render: ->
    dict = @options.entity.toJSON()
    dict.title = @options.entity.title()
    $(@el).addClass('showView').addClass('panel').html(@template(dict))
    return this
