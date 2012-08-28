class Cocupu.Routers.ModelsRouter extends Backbone.Router
  initialize: (options) ->
    @models = new Cocupu.Collections.ModelsCollection()
    @models.reset options.models

  routes:
    ":id/new"    : "newEntity"
    "index"      : "index"
    "drive"      : "drive"
    ":id/search" : "search"
    "entity/:id" : "showEntity"
    ":id/edit"   : "edit"
    ":id"        : "show"
    ".*"         : "index"

  scrolling: false


  updateWidth: (options) ->
    # 10 is for the margin width
    children = ($(item).width() for item in $('#panels').children())
    return if children.length == 0
    result = children.reduce (t, i) ->
      t + i
    $('#panels').width(result + 210)
    if !options || options.scroll == true
      $pane = $($('#panels').children().last())
      $.scrollTo({top: '+=0px', left: $pane.position()['left']}, 800)

  addToPanels: (pane)->
    $pane = $(pane)
    $('#panels').append($pane)
    @updateWidth()
    
  index: ->
    @view = new Cocupu.Views.RootView(models: @models)
    $(".full-width-container").replaceWith(@view.render().el)

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

    entity = new Cocupu.Models.Entity({id: id})
    view = new Cocupu.Views.Entities.ShowView(model: entity)
    @addToPanels(view.render().el)
    entity.fetch()

  newEntity: (id) ->
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0

    $(".searchPane").remove()
    model = new Cocupu.Models.Entity({model_id: id})
    @view = new Cocupu.Views.Entities.NewView(model: model)
    $("#panels").before(@view.render().el)


  search: (id) ->
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0
    model = @models.get(id)

    $(".searchPane").remove()
    @view = new Cocupu.Views.Entities.SearchView(model: model)
    $("#panels").before(@view.render().el)
    
  edit: (id) ->
    # Draw the model bar if it's not on the page (e.g. direct to url #/:id)
    @index() if $(".models").length == 0
    model = @models.get(id)
    $(".searchPane").remove()
    @view = new Cocupu.Views.Models.EditView(model: model)
    $("#panels").before(@view.render().el)

