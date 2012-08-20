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
#    @model.unbind("change", @modelChanged)
    false


  search : ->
    #TODO searches may come back out of sequence, so send a seq number with
    return if @field.val().length < 3
    #TODO set url for @collection
    @collection.fetch()

  addAll : ->
    this.$('.results').empty()
    this.collection.each(@addOne)

  addOne: (result) ->
    view = new Cocupu.Views.Entities.SearchResultView(result: result)
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

