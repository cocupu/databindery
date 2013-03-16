class Cocupu.Models.Field extends Backbone.Model
    
class Cocupu.Collections.FieldsCollection extends Backbone.Collection
  model: Cocupu.Models.Field
  url: () ->
    '/models/' + this.model_id + "/fields"

  defaults:
    type: "text"