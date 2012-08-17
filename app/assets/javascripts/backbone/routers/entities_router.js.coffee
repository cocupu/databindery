class Cocupu.Routers.EntitiesRouter extends Backbone.Router
  initialize: (options) ->
    @entities = new Cocupu.Collections.EntitiesCollection()
    @entities.reset options.entities
    @models = new Cocupu.Collections.ModelsCollection()
    @models.reset options.models

  routes:
    "new"      : "newEntity"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newEntity: ->
    @view = new Cocupu.Views.Entities.NewView(collection: @entities)
    $("#entities").html(@view.render().el)

  index: ->
    @view = new Cocupu.Views.Entities.IndexView(entities: @entities)
    $("#entities").html(@view.render().el)

  show: (id) ->
    entity = @entities.get(id)

    @view = new Cocupu.Views.Entities.ShowView(model: entity)
    $("#entities").html(@view.render().el)

  edit: (id) ->
    entity = @entities.get(id)

    @view = new Cocupu.Views.Entities.EditView(model: entity)
    $("#entities").html(@view.render().el)
