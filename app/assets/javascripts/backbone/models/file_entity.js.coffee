class Cocupu.Models.FileEntity extends Backbone.Model
  urlRoot : '/file_entities'

  defaults:
    binding_id: null
    persistent_id: null

class Cocupu.Collections.FileEntitiesCollection extends Backbone.Collection
  model: Cocupu.Models.FileEntity
  url: '/file_entities'

