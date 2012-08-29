Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.EditView extends Backbone.View
  template : JST["backbone/templates/models/edit"]

  events :
    "submit .metadata" : "addField"
    "submit .associations" : "addAssociation"
    "change input[name='label']" : "saveLabel"

  addField : (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.FieldsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.metadata').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    self = this
    collection.create data, success: (element) ->
      fields = self.model.get('fields')
      fields.push(element.toJSON())
      self.model.set('fields', fields)
      self.render()

  addAssociation: (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.AssociationsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.associations').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    self = this
    collection.create data, success: (element) ->
      fields = self.model.get('associations')
      fields.push(element.toJSON())
      #TODO, set the element.label?
      self.model.set('associations', fields)
      self.render()

  # TODO should we re-index after changing label?
  saveLabel: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.set(label: $(e.currentTarget).val())
    @model.save()
    


  render : ->
    dict = @model.toJSON()
    console.log "Rendering", dict
    dict.models = window.router.models
    $(@el).addClass('searchPane').addClass('editor').addClass('panel').html(@template(dict))

    return this
