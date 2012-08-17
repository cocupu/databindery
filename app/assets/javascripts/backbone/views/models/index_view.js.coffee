Cocupu.Views.Models ||= {}

class Cocupu.Views.Models.IndexView extends Backbone.View
  template: JST["backbone/templates/models/index"]

  initialize: () ->
    @options.models.bind('reset', @addAll)

  events: {
    "click li.model > a" : "highlightModel"
  },

  highlightModel: (event) ->
    $('li.model').removeClass('active')
    $(event.currentTarget).parent().addClass('active')


  addAll: () =>
    @options.models.each(@addOne)

  addOne: (model) =>
    view = new Cocupu.Views.Models.ModelView({model : model})
    @$("ul").append(view.render().el)

  render: =>
    $(@el).html(@template(models: @options.models.toJSON() ))
    @addAll()

    return this
