Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.IndexView extends Backbone.View
  template: JST["backbone/templates/data_sources/index"]
  id: 'data-sources'

  render: ->
    $(@el).addClass('tab-pane').html(@template())
    return this




