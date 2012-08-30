Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationView extends Backbone.View
  template: JST["backbone/templates/entities/showAssociation"]
  values: []

  initialize: (options) ->
    @options = options
    _.bindAll(this, 'add')
    if options.values
      @values = options.values

  addToTable: (num, text) ->
    $('table', $(@el)).append("<tr><td><a href=\"#entity/" + num + "\">" + text + "</a></td></tr>")
  

  add: (node) ->
    association = new Cocupu.Models.Association(code: @model.code)
    association.url = "/nodes/" +@options.node.id+ "/associations"
    if node.hasClass('driveFile')
      ## TODO, send the file_name too?
      file = new Cocupu.Models.FileEntity(binding: node.attr('data-id'))
      file.save({}, success: (model, response) ->
          console.log "success", model.id
          association.set(target_id: file.id)
          association.save()
          @addToTable(file.id, node.text())
      )
    else
      association.set(target_id: node.attr('data-id'))
      association.save()
      @addToTable(node.attr('data-id'), node.text())

  render: ->
    dict = @model
    $(@el).addClass('association').html(@template(dict))
    node = $(@el)
    $(@el).droppable(drop: ( event, ui ) ->
      self.add(ui.draggable)
    )
    count = 0
    self = this
    $.each(@values, (n, val)->
      self.addToTable(val.id, val.title)
      count++
    )
    while count < 4
      self.addToTable(null, '')
      count++
    return this


