Cocupu.Views.Entities ||= {}

class Cocupu.Views.RootView extends Backbone.View
  template: JST["backbone/templates/rootView"]

  render: ->
    console.log "Rendering root view"
    $(@el).addClass('full-width-container').html(@template())
    $('#menu-nav-tabs a', $(@el)).click((e) -> 
      e.preventDefault()
      $(this).tab('show')
    )
    view = new Cocupu.Views.Models.IndexView(models: @options.models)
    $("#menu-tab-content", $(@el)).append(view.render().el)
    view = new Cocupu.Views.DataSources.IndexView()
    $("#menu-tab-content", $(@el)).append(view.render().el)
    return this



