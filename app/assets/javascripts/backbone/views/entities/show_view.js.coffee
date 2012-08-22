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
    structure = @model.model()
    $.each(structure.get('fields'), (n, field) ->
      field.value = data[field.code]
      elm = new Cocupu.Views.Entities.ShowFieldView(model: field).render().el
      self.$('form .form-actions').before(elm)
    )
      
    associations = new Cocupu.Models.Association
    associations.url = '/nodes/' + @model.id + '/associations'
    elm = new Cocupu.Views.Entities.ShowAssociationsView(model: associations, structure: structure).render().el
    this.$('.panel-body').append(elm)
    associations.fetch()

  close: ->
    @remove()
    @unbind()
    @model.unbind("change", @changed)
    false

  render: ->
    template = {}
    $(@el).addClass('showView').addClass('panel').html(template)
    return this
