Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchView extends Backbone.View
  template : JST["backbone/templates/entities/search"]
  
  searchItems: []

  events: {
    "keyup input.search-query": "search"
    "click .close": "close"
  }

  close: ->
    @remove()
    @unbind()
    @collection.unbind("reset", @addAll)
    false


  search : (event) ->
    return if @field.val().length < 3
    clearTimeout(@searching )
    self = this
    @searching = setTimeout \
      ->
        #TODO set url for @collection
        self.collection.fetch()
        false
      ,
      300  #delay of 300ms

  addAll : ->
    this.$('.results').empty()
    this.collection.each(@addOne)

  addOne: (result) ->
    view = new Cocupu.Views.Entities.SearchResultView(model: result)
    this.$('.results').append(view.render().el)
    
  initialize: ->
      _.bindAll(this, 'addOne', 'addAll');
      @collection = @model.entities()
      @collection.bind('reset', @addAll)
      @collection.fetch()

  render : ->
    $(@el).addClass('searchPane').addClass('panel').html(@template(@model.toJSON() ))
    @field = $(".search-query", @el)

    this.$("form").backboneLink(@model)

    return this

