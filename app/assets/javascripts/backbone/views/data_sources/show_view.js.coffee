Cocupu.Views.DataSources ||= {}

class Cocupu.Views.DataSources.ShowView extends Backbone.View
  template: JST["backbone/templates/data_sources/show"]
  id: 'data-sources'

  initialize: ->
    _.bindAll(this, 'changed')
    @model.bind('change', @changed)

  changed: ->
    console.log @model.toJSON()
     
    this.$('.panel').append("hulloo!")

    #self = this
    #data = @model.get('data')
    #structure = @model.model()
    #$.each(structure.get('fields'), (n, field) ->
    #  field.value = data[field.code]
    #  elm = new Cocupu.Views.Entities.ShowFieldView(model: field).render().el
    #  self.$('form .form-actions').before(elm)
    #)
      
  render: ->
    $(@el).addClass('showView').addClass('panel').html(@template())
    return this

