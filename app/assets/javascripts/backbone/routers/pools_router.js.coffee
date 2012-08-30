class Cocupu.Routers.PoolsRouter extends Backbone.Router
  initialize: (options) ->
    if (options.pool)
      @pool = new Cocupu.Models.Pool(options.pool)
    else
      @pools = new Cocupu.Collections.PoolsCollection()
      @pools.reset options.pools

  routes:
    "new"      : "newEntity"
    "index"    : "index"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    if @pool
      @view = new Cocupu.Views.Pools.ShowView(model: @pool)
      $(".full-width-container").append(@view.render().el)
    else
      @view = new Cocupu.Views.Pools.IndexView(collection: @pools)
      $(".full-width-container").append(@view.render().el)

  show: (id) ->
    pool = @pools.get(id)

    @view = new Cocupu.Views.Pools.ShowView(model: pool)
    $(".full-width-container").append(@view.render().el)

