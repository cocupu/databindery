Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.DriveFileView extends Backbone.View
  template : JST["backbone/templates/data_sources/drive_file"]
  tagName: 'tr'

  render : ->
    dict = @model.toJSON()
    console.log "Id is ", @model.id
    $(@el).addClass('driveFile').attr('data-id', @model.id).html(@template(dict))
    $(@el).draggable(	appendTo: "body", helper: "clone")

    return this



