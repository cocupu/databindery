class Cocupu.Routers.ModelsRouter extends Backbone.Router
  initialize: (options) ->
    @models = new Cocupu.Collections.ModelsCollection()
    @models.reset options.models

  routes:
    "new"        : "newEntity"
    "index"      : "index"
    "drive"      : "drive"
    ":id/search" : "search"
    "entity/:id" : "showEntity"
    ":id/edit"   : "edit"
    ":id"        : "show"
    ".*"         : "index"

  newModel: ->
    @view = new Cocupu.Views.Models.NewView(collection: @models)
    $("#models").html(@view.render().el)

  addToPanels: (pane)->
    orig_width = $('#panels').width()
    new_width = $(pane).width()
    $('#panels').width( orig_width + new_width)
    $('#panels').append(pane)
    

  index: ->
    @view = new Cocupu.Views.RootView(models: @models)
    $(".full-width-container").append(@view.render().el)

  drive: (id) ->
    @index() if $(".models").length == 0

    entity = new Cocupu.Collections.DataSourcesCollection()
    view = new Cocupu.Views.DataSources.ShowView(collection: entity)
    #$("#panels").append(view.render().el)
    @addToPanels(view.render().el)
    entity.fetch()

  showEntity: (id) ->
  
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0



    $("#panels .showView").remove()
    entity = new Cocupu.Models.Entity({id: id})
    view = new Cocupu.Views.Entities.ShowView(model: entity)
    @addToPanels(view.render().el)
    #$("#panels").append(view.render().el)
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

