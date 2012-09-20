class Cocupu.Routers.PoolsRouter extends Backbone.Router
  initialize: (options) ->
    @identity = options.identity
    if (options.pool)
      @pool = new Cocupu.Models.Pool(options.pool)
    else
      @pools = new Cocupu.Collections.PoolsCollection()
      @pools.reset options.pools

  routes:
    "new"      : "newPool"
    "index"    : "index"
    ":id"      : "show"
    ":id/edit" : "edit"
    ".*"       : "index"

  index: ->
    if @pool
      @view = new Cocupu.Views.Pools.ShowView(model: @pool)
      $(".full-width-container").html(@view.render().el)
    else
      @view = new Cocupu.Views.Pools.IndexView(collection: @pools)
      $(".full-width-container").html(@view.render().el)

  newPool: ->
      @view = new Cocupu.Views.Pools.NewView(model: new Cocupu.Models.Pool)
      $(".full-width-container").html(@view.render().el)
    

  show: (id) ->
    pool = @pools.get(id)

    @view = new Cocupu.Views.Pools.ShowView(model: pool)
    $(".full-width-container").html(@view.render().el)

  edit: (id) ->
    pool = @pools.get(id)
    @view = new Cocupu.Views.Pools.EditView(model: pool)
    $(".full-width-container").html(@view.render().el)


