Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.NewView extends Backbone.View
  template: JST["backbone/templates/entities/new"]

  events:
    "submit": "save"

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.unset("errors")

    data = {}
    $.each(this.$('form').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    @model.save(data: data,
      success: (entity) ->
        @model = entity
        window.router.navigate(@model.get('model_id') + "/search", true)

      error: (entity, jqXHR) =>
         @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).addClass('searchPane').addClass('panel').html(@template())
    structure = @model.model()
    self = this
    $.each(structure.get('fields'), (n, field) ->
      field.value = ''
      elm = new Cocupu.Views.Entities.ShowFieldView(model: field).render().el
      self.$('form .form-actions').before(elm)
    )
    return this
  
  changed: ->
    dict = @model.toJSON()
    dict.title = @model.title()
    template = @template(dict)
  
    $(@el).addClass('showView').addClass('panel').html(template)
    self = this
    data = @model.get('data')
    structure = @model.model()
    $.each(structure.get('fields'), (n, field) ->
      field.value = data[field.code]
      elm = new Cocupu.Views.Entities.ShowFieldView(model: field).render().el
      self.$('form .form-actions').before(elm)
    )
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
