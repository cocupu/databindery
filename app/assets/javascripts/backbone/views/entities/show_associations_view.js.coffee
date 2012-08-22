Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.ShowAssociationsView extends Backbone.View
  initialize: (options) ->
    @options = options
    _.bindAll(this, 'changed')
    @model.bind('change', @changed)
  close: ->
    @remove()
    @unbind()
    @model.unbind("change", @changed)
    false

  changed: ->
    self = this
    structure = @options.node.model() #TODO make sure this is memoize and not reloading from the server.
    $.each(structure.get('associations'), (n, field) ->
      elm = new Cocupu.Views.Entities.ShowAssociationView(model: field, node: self.options.node, values: self.model.attributes[field.name]).render().el
      $(self.el).append(elm)
    )
    # any undefined associations
    elm = new Cocupu.Views.Entities.ShowAssociationView(model: {name: 'Uncategorized'}, node: self.options.node, values: @model.attributes['undefined']).render().el
    $(@el).append(elm)
    

  render: ->
    $(@el).addClass('associations')
    return this



