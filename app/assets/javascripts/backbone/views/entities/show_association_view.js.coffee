Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationView extends Backbone.View
  template: JST["backbone/templates/entities/showAssociation"]
  values: []

  initialize: (options) ->
    if options.values
      @values = options.values

  addToTable: (text) ->
    $('table', $(@el)).append("<tr><td>" + text + "</td></tr>")
  

  add: (node) ->
    #TODO perhaps (PUT /nodes/37/associations  {name: recordings, target: node.id?})
    # save this model
    console.log node
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


