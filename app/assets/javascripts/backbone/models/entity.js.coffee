class Cocupu.Models.Entity extends Backbone.Model
  urlRoot : '/nodes'
  paramRoot: 'node'

  url: ->
    if @id
      @urlRoot + '/' + @id
    else
      '/' + window.router.identity + '/' + window.router.pool.short_name + @urlRoot

  defaults:
    data: null
    associations: {}
    content: null
    persistent_id: null
    model_id: null

  title: ->
    m = @model()
    d = @get("data")
    label =d[m.get('label')]
    if !!label then label else @get('persistent_id')
    
  model: ->
    # TODO memoize
    window.router.models.get(@get("model_id"))

class Cocupu.Collections.EntitiesCollection extends Backbone.Collection
  model: Cocupu.Models.Entity
  url: '/nodes'
