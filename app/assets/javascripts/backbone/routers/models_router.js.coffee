class Cocupu.Routers.ModelsRouter extends Backbone.Router
  initialize: (options) ->
    @models = new Cocupu.Collections.ModelsCollection()
    @models.reset options.models

  routes:
    "new"        : "newEntity"
    "index"      : "index"
    ":id/search" : "search"
    "entity/:id" : "showEntity"
    ":id/edit"   : "edit"
    ":id"        : "show"
    ".*"         : "index"

  newModel: ->
    @view = new Cocupu.Views.Models.NewView(collection: @models)
    $("#models").html(@view.render().el)

  index: ->
    @view = new Cocupu.Views.Models.IndexView(models: @models)
    $("#models").html(@view.render().el)

  show: (id) ->
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0
    model = @models.get(id)

    @view = new Cocupu.Views.Models.ShowView(model: model)
    $("#panels").prepend(@view.render().el)

  showEntity: (id) ->
  
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0



    $("#panels .showView").remove()
    entity = new Cocupu.Models.Entity({id: id})
    view = new Cocupu.Views.Entities.ShowView(model: entity)
    $("#panels").append(view.render().el)
    entity.fetch()


  search: (id) ->
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0
    model = @models.get(id)

    $("#panels .searchPane").remove()
    @view = new Cocupu.Views.Entities.SearchView(model: model)
    $("#panels").prepend(@view.render().el)
    

  edit: (id) ->
    model = @models.get(id)

    @view = new Cocupu.Views.Models.EditView(model: model)
    $("#entities").html(@view.render().el)

