Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationView extends Backbone.View
  template: JST["backbone/templates/entities/showAssociation"]
  values: []

  initialize: (options) ->
    #TODO look these up. perhaps (/nodes/37/associations/recordings)
    if options.values
      @values = options.values

  render: ->
    dict = @model
    $(@el).addClass('association').html(@template(dict))
    $(@el).droppable(drop: ( event, ui ) ->
      $( "<div></div>" ).text( ui.draggable.text() ).appendTo( this )
    )
    node = $(@el)
    count = 0
    $.each(@values, (n, val)->
      $('table', node).append("<tr><td>" + val + "</td></tr>")
      count++
    )
    while count < 4
      $('table', node).append("<tr><td></td></tr>")
      count++
    return this


