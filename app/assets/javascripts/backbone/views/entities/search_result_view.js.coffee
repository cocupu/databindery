Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchResultView extends Backbone.View
  template : JST["backbone/templates/entities/search_result"]
  tagName: 'tr'

  events: {
    'click' : 'clicked'
  }

  clicked: ->
    $("#panels .showView").remove()
    view = new Cocupu.Views.Entities.ShowView(entity: @options.result)
    $("#panels").append(view.render().el)

    false


  render : ->
    result = @options.result
    dict = result.toJSON()
    dict.title = result.title()
    $(@el).addClass('searchResult').html(@template(dict))

    return this


