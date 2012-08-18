Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchResultView extends Backbone.View
  template : JST["backbone/templates/entities/search_result"]
  tagName: 'tr'

  events: {
  }


  render : ->
    $(@el).addClass('searchResult').html(@template(@options.result))

    return this


