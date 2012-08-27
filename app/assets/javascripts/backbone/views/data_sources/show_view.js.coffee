Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.ShowView extends Backbone.View
  template: JST["backbone/templates/data_sources/show"]
  id: 'data-sources'

  initialize: ->
    _.bindAll(this, 'addAll', 'addOne')
    @collection.bind('reset', @addAll)

  close: ->
    @remove()
    @unbind()
    @collection.unbind("reset", @addAll)
    false

  addAll: ->
    this.collection.each(@addOne)

  addOne: (result) ->
    console.log result
    view = new Cocupu.Views.DataSources.DriveFileView(model: result)
    this.$('table').append(view.render().el)

  render: ->
    $(@el).addClass('showView').addClass('panel').html(@template())
    return this

