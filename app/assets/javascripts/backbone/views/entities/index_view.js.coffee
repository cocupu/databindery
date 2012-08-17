Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.IndexView extends Backbone.View
  template: JST["backbone/templates/entities/index"]

  initialize: () ->
    @options.entities.bind('reset', @addAll)

  addAll: () =>
    @options.entities.each(@addOne)

  addOne: (entity) =>
    view = new Cocupu.Views.Entities.EntityView({model : entity})
    @$("ul").append(view.render().el)

  render: =>
    $(@el).html(@template(entities: @options.entities.toJSON() ))
    @addAll()

    return this
