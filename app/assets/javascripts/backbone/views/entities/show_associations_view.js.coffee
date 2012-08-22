Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationsView extends Backbone.View
  #template: JST["backbone/templates/entities/showAssociations"]
  initialize: ->
    _.bindAll(this, 'changed')
    @model.bind('change', @changed)
  close: ->
    @remove()
    @unbind()
    @model.unbind("change", @changed)
    false

  changed: ->
    structure = @options.structure
    self = this
    $.each(structure.get('associations'), (n, field) ->
      elm = new Cocupu.Views.Entities.ShowAssociationView(model: field, values: self.model.attributes[field.name]).render().el
      $(self.el).append(elm)
    )
    # any undefined associations
    elm = new Cocupu.Views.Entities.ShowAssociationView(model: {name: 'Uncategorized'}, values: @model.attributes['undefined']).render().el
    $(@el).append(elm)
    

  render: ->
    $(@el).addClass('associations')
    return this



