class Cocupu.Models.Model extends Backbone.Model
  paramRoot: 'model'

  defaults:
    name: null
    label: null
    fields: null

  entities: (options) ->
    collection = new Cocupu.Collections.EntitiesCollection
    collection.url = '/models/' + @id + '/nodes/search.json'
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
