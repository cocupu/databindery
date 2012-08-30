Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.EditView extends Backbone.View
  template : JST["backbone/templates/models/edit"]
  events :
    "submit .metadata" : "addField"
    "submit .associations" : "addAssociation"
    "change input[name='label']" : "saveLabel"
    "click .association-name,.field-name": "editorOn"
    "submit form.fields": "doNothing"


  initialize : ->
    _.bindAll(this, 'changed', 'editorSave')
    @model.bind("reset", @changed)

  close: ->
    @remove()
    @unbind()
    @model.unbind("reset", @changed)
    false

  doNothing: -> false

  changed: ->
    dict = @model.toJSON()
    dict.models = window.router.models
    $(@el).html(@template(dict))


  addField : (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.FieldsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.metadata').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    model = @model
    collection.create data, success: (element) ->
      model.fetch success : ->
        model.trigger("reset")

  addAssociation: (e) ->
    e.preventDefault()
    e.stopPropagation()

    collection = new Cocupu.Collections.AssociationsCollection()
    collection.model_id = @model.id
    data = {}
    $.each(this.$('form.associations').serializeArray(), (n, o) ->
      data[o.name] = o.value
    )
    model = @model
    collection.create data, success: (element) ->
      model.fetch success : ->
        model.trigger("reset")

  editorOn: (e) ->
    e.preventDefault()
    e.stopPropagation()
    $td = $(e.currentTarget)
    console.log $td.attr('data-behavior')
    return if $td.attr('data-behavior') == 'editor'
    $td.attr('data-behavior', 'editor')
    text = $td.html()
    editor = $('<input type="text" name="editor">')
    editor.val(text)
    $td.html(editor)
    editor.focus()
    editor.select()
    editor.blur @editorSave
    true

  editorSave: (e) ->
    editor = $(e.currentTarget)
    $td = editor.closest('td')
    $td.removeAttr('data-behavior')
    @model.setTypeName $td.attr('data-type'), $td.attr('data-code'), editor.val()
    $td.html(editor.val())


    

  # TODO should we re-index after changing label?
  saveLabel: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @model.set(label: $(e.currentTarget).val())
    @model.save()
    


  render : ->
    dict = @model.toJSON()
    dict.models = window.router.models
    $(@el).addClass('palate-drawer').addClass('editor').addClass('panel').html(@template(dict))

    return this
