class Cocupu.Models.Model extends Backbone.Model
  paramRoot: 'model'

  defaults:
    name: null
    label: null
    fields: null

  entities: (options) ->
    collection = new Cocupu.Collections.EntitiesCollection
    collection.url = '/models/' + @id + '/nodes.json'
    collection

class Cocupu.Collections.ModelsCollection extends Backbone.Collection
  model: Cocupu.Models.Model
  url: '/models'
