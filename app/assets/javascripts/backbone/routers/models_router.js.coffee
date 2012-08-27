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

  scrolling: false

  newModel: ->
    @view = new Cocupu.Views.Models.NewView(collection: @models)
    $("#models").html(@view.render().el)


  updateWidth: (options) ->
    # 10 is for the margin width
    result = ($(item).width() for item in $('#panels').children()).reduce (t, i) ->
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

