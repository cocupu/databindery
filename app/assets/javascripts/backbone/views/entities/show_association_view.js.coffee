Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationView extends Backbone.View
  template: JST["backbone/templates/entities/showAssociation"]

  render: ->
    dict = @model
    console.log "ASSOC: ", dict
    $(@el).addClass('association').html(@template(dict))
    $(@el).droppable(drop: ( event, ui ) ->
      $( "<div></div>" ).text( ui.draggable.text() ).appendTo( this )
    )
    return this


