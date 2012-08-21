Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchResultView extends Backbone.View
  template : JST["backbone/templates/entities/search_result"]
  tagName: 'tr'

  events: {
    'click' : 'clicked'
  }

  clicked: ->
    $("#panels .showView").remove()
    view = new Cocupu.Views.Entities.ShowView(model: @model)
    $("#panels").append(view.render().el)
    view.changed() #force a call to changed, because the model is already loaded

    false


  render : ->
    dict = @model.toJSON()
    dict.title = @model.title()
    $(@el).addClass('searchResult').html(@template(dict))

    return this


