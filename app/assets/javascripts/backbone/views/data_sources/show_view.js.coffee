Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.ShowView extends Backbone.View
  template: JST["backbone/templates/data_sources/show"]
  id: 'data-sources'

  initialize: ->
    _.bindAll(this, 'addAll', 'addOne')
    @collection.bind('reset', @addAll)

  events: {
    "click .close": "close"
  }

  close: ->
    @remove()
    @unbind()
    window.router.updateWidth()
    @collection.unbind("reset", @addAll)
    false

  addAll: ->
    this.collection.each(@addOne)
    window.router.updateWidth()

  addOne: (result) ->
    view = new Cocupu.Views.DataSources.DriveFileView(model: result)
    this.$('table').append(view.render().el)

  render: ->
    $(@el).addClass('palate-drawer').addClass('drive').addClass('panel').html(@template())
    return this

