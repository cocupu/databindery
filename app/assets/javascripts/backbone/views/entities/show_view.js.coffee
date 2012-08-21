Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowView extends Backbone.View
  template: JST["backbone/templates/entities/show"]

  events: {
    "click .close": "close"
  }

  initialize: ->
    _.bindAll(this, 'changed')
    @model.bind('change', @changed)

  changed: ->
    dict = @model.toJSON()
    dict.title = @model.title()
    template = @template(dict)
  
    $(@el).addClass('showView').addClass('panel').html(template)
    self = this
    data = @model.get('data')
    $.each(@model.model().get('fields'), (n, field) ->
      field.value = data[field.code]
      elm = new Cocupu.Views.Entities.ShowFieldView(model: field).render().el
      self.$('form .form-actions').before(elm)
    )

  close: ->
    @remove()
    @unbind()
    @model.unbind("change", @changed)
    false

  render: ->
    template = {}
    $(@el).addClass('showView').addClass('panel').html(template)
    return this
