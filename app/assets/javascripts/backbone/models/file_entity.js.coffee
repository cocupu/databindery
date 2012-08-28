class Cocupu.Models.FileEntity extends Backbone.Model
  urlRoot : '/file_entities'

  defaults:
    binding: null

class Cocupu.Collections.FileEntitiesCollection extends Backbone.Collection
  model: Cocupu.Models.FileEntity
  url: '/file_entities'

