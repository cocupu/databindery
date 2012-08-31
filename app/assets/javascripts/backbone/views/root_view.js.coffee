Cocupu.Views.Entities ||= {}

class Cocupu.Views.RootView extends Backbone.View
  template: JST["backbone/templates/rootView"]

  render: ->
    $(@el).addClass('full-width-container').html(@template())
    $('#menu-nav-tabs a', $(@el)).click((e) -> 
      e.preventDefault()
      $(this).tab('show')
    )
    view = new Cocupu.Views.Models.IndexView(collection: @options.models)
    $("#menu-tab-content", $(@el)).append(view.render().el)
    view = new Cocupu.Views.DataSources.IndexView()
    $("#menu-tab-content", $(@el)).append(view.render().el)
    return this



