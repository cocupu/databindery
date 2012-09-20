Cocupu.Views.Pools ||= {}

class Cocupu.Views.Pools.EditView extends Backbone.View
  template : JST["backbone/templates/pools/edit"]

  initialize : ->
    _.bindAll(this, 'update')

  events :
    "submit" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()
    pool = @model
    $.each(this.$('form').serializeArray(), (n, o) ->
      pool.set(o.name, o.value)
    )

    @model.save(null,
      success : (entity) =>
        @model = entity
        window.location.hash = ""
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    return this
