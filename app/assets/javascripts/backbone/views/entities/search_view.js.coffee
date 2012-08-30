Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchView extends Backbone.View
  template : JST["backbone/templates/entities/search"]
  
  searchItems: []

  events: {
    "keyup input.search-query": "search"
    "click .close": "close"
  }

  initialize: ->
      _.bindAll(this, 'addOne', 'addAll', 'search')
      @collection = @model.entities()
      @collection.bind('reset', @addAll)
      @collection.fetch()


  close: ->
    @remove()
    @unbind()
    window.router.updateWidth(scroll: false)
    @collection.unbind("reset", @addAll)
    false


  search : (event) ->
    return if @field.val().length < 3
    clearTimeout(@searching )
    search_url = '/models/' + @model.id + '/nodes/search.json?q='
    self = this
    @searching = setTimeout \
      ->
        self.collection.url = search_url + self.$('#query').val()
        self.collection.fetch()
        false
      ,
      300  #delay of 300ms

  addAll : ->
    this.$('.results').empty()
    this.collection.each(@addOne)
    window.router.updateWidth(scroll: false)

  addOne: (result) ->
    view = new Cocupu.Views.Entities.SearchResultView(model: result)
    this.$('.results').append(view.render().el)
    
  render : ->
    $(@el).addClass('palate-drawer').addClass('panel').html(@template(@model.toJSON() ))
    @field = $(".search-query", @el)

    return this

