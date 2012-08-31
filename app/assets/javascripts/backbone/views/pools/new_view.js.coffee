Cocupu.Views.Pools ||= {}

class Cocupu.Views.Pools.NewView extends Backbone.View
  template: JST["backbone/templates/pools/new"]

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
        window.router.pools.add(entity)
        window.router.navigate("/index", true)

      error: (entity, jqXHR) =>
         @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )


  render: =>
    $(@el).html(@template(@model.toJSON()))

    return this


