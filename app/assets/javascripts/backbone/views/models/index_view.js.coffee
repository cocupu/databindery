Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.IndexView extends Backbone.View
  template: JST["backbone/templates/models/index"]

  tagName: 'ul'
  id: 'models'

  initialize: () ->
    @collection.bind('reset', @addAll)
    @collection.bind('add', @addOne)

  close: ->
    @remove()
    @unbind()
    @collection.unbind("reset", @addAll)
    @collection.unbind('add', @addOne)
    false

  events: {
    "click li.model > a" : "highlightModel"
  },

  highlightModel: (event) ->
    $('li.model').removeClass('active')
    $(event.currentTarget).parent().addClass('active')


  addAll: () =>
    this.$('li.model').remove()
    @collection.each(@addOne)

  addOne: (model) =>
    view = new Cocupu.Views.Models.ModelView({model : model})
    $('#new-entity', $(@el)).before(view.render().el)

  render: =>
    $(@el).addClass('tab-pane active models nav nav-pills nav-stacked').html(@template(models: @collection.toJSON() ))
    @addAll()

    return this
