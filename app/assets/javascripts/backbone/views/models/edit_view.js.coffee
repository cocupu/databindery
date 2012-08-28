Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.EditView extends Backbone.View
  template : JST["backbone/templates/models/edit"]

  events :
    "submit .metadata" : "addField"
    "submit .associations" : "addAssociation"

  # TODO - save label
  # Refresh after adding field/association
  # Question, should we re-index after changing label?
  addField : (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.FieldsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.metadata').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    collection.create(data)

  addAssociation: (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.AssociationsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.metadata').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    collection.create(data)


  render : ->
    dict = @model.toJSON()
    dict.models = window.router.models
    $(@el).addClass('searchPane').addClass('editor').addClass('panel').html(@template(dict))

    this.$("form").backboneLink(@model)

    return this
