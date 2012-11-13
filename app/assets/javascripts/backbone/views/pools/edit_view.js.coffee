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
    pool.set('name', $("input[name='name']").val())
    pool.set('short_name', $("input[name='short_name']").val())
    pool.set('description', $("textarea[name='description']").val())
    pool.set('access_controls', @access_controls())

    @model.save(null,
      success : (entity) =>
        @model = entity
        window.location.hash = ""
    )

  access_controls : ->
    access_controls = []
    $("select[name^='permission_access[']").each (index, element) =>
      $element = $(element)
      name = $element.attr('name')
      match = /.*\[([0-9]+)\]/.exec name
      idx = match[1]
      access_controls.push {access: $element.val(), identity: $("input[name^='permission_identity["+idx+"]']").val()}
    new_user = $('input[name=permission_identity_new]').val()
    if new_user != ''
      access_controls.push {access: $("select[name='permission_access_new']").val(), identity: new_user}
    access_controls

  render : ->
    $(@el).html(@template(@model.toJSON() ))
    return this
