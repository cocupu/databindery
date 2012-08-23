Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.ShowView extends Backbone.View
  template: JST["backbone/templates/data_sources/show"]
  id: 'data-sources'

  render: ->
    template = {}
    $(@el).addClass('showView').addClass('panel').html(template)
    return this

