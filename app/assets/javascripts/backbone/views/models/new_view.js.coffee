Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.NewView extends Backbone.View
  template: JST["backbone/templates/models/new"]

  events:
    "submit": "save"

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.unset("errors")

    @model.set(o.name, o.value) for o in this.$('form').serializeArray()
    @model.save({},
      success: (entity) ->
        @model = entity
        window.router.models.add(entity)
        window.router.navigate(@model.id + "/edit", true)

      error: (entity, jqXHR) =>
         @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).addClass('palate-drawer').addClass('panel').html(@template())
    return this
  
