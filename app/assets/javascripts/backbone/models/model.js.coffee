class Cocupu.Models.Model extends Backbone.Model
  urlRoot : '/models'
  paramRoot: 'model'

  url: ->
    if @id
      @urlRoot + '/' + @id
    else
     window.router.identity + '/' + window.router.pool.short_name + @urlRoot

  defaults:
    name: null
    label: null
    fields: null

  entities: (options) ->
    collection = new Cocupu.Collections.EntitiesCollection
    collection.url = '/' + window.router.identity + '/' + window.router.pool.short_name + @urlRoot + '/' + @id + '/nodes/search.json'
    collection
 
  setTypeName: (type, code, name) ->
    elements = @get(type)
    result = (item for item in elements when item.code is code)
    result[0].name = name
    @set(type, elements)
    @save()
    

class Cocupu.Collections.ModelsCollection extends Backbone.Collection
  model: Cocupu.Models.Model
  url: '/models'
