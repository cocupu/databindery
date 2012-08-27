Cocupu.Views.Entities ||= {}

class Cocupu.Views.DataSources.DriveFileView extends Backbone.View
  template : JST["backbone/templates/data_sources/drive_file"]
  tagName: 'tr'

  render : ->
    dict = @model.toJSON()
    $(@el).html(@template(dict))

    return this



