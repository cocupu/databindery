Cocupu.Views.Entities ||= {}

class Cocupu.Views.Entities.SearchView extends Backbone.View
  template : JST["backbone/templates/entities/search"]
  
  searchItems: []


  events: {
    "keyup input.search-query": "search"
  }

  search : ->
    #TODO searches may come back out of sequence, so send a seq number with
    return if @field.val().length < 3
    @searchItems = []
    target = $("table", this.el)
    target.empty()
    results = [{title: 'One result for ' + @field.val()}, {title: 'Another result for ' + @field.val()}]
    self = this
    $.each(results, (n, result) ->
      self.searchItems.push(new Cocupu.Views.Entities.SearchResultView(result: result)))
    $.each(@searchItems, (n, result) ->
      target.append(result.render().el))

  render : ->
    $(@el).addClass('searchPane').html(@template(@model.toJSON() ))
    @field = $(".search-query", @el)

    this.$("form").backboneLink(@model)

    return this

