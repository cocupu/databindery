Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchResultView extends Backbone.View
  template : JST["backbone/templates/entities/search_result"]
  tagName: 'tr'

  events: {
    'click' : 'clicked'
  }

  clicked: (e) ->
    e.preventDefault()
    $("#panels .showView").remove()
    view = new Cocupu.Views.Entities.ShowView(model: @model)
    $("#panels").append(view.render().el)
    view.changed() #force a call to changed, because the model is already loaded

    # don't trigger the route handler, just update the url
    window.router.navigate('/entity/' + @model.id, {trigger: false} )


  render : ->
    dict = @model.toJSON()
    dict.title = @model.title()
    $(@el).addClass('searchResult').html(@template(dict))
    $(@el).draggable(	appendTo: "body", helper: "clone")

    return this


