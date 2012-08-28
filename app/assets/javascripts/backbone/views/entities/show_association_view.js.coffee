Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationView extends Backbone.View
  template: JST["backbone/templates/entities/showAssociation"]
  values: []

  initialize: (options) ->
    @options = options
    _.bindAll(this, 'add')
    if options.values
      @values = options.values

  addToTable: (text) ->
    $('table', $(@el)).append("<tr><td>" + text + "</td></tr>")
  

  add: (node) ->
    # TODO if it's a file, need to make a new FileEntity and associate it.
    association = new Cocupu.Models.Association(name: @model.name)
    association.url = "/nodes/" +@options.node.id+ "/associations"
    if node.hasClass('driveFile')
      file = new Cocupu.Models.FileEntity(binding: node.attr('data-id'))
      file.save({}, success: (model, response) ->
          console.log "success", model.id
          association.set(target_id: file.id)
          association.save()
      )
    else
      association.set(target_id: node.attr('data-id'))
      association.save()
    @addToTable(node.text())

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
      self.addToTable(val.title)
      count++
    )
    while count < 4
      self.addToTable('')
      count++
    return this


