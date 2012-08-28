class Cocupu.Models.Association extends Backbone.Model
  paramRoot: 'association'

class Cocupu.Collections.AssociationsCollection extends Backbone.Collection
  model: Cocupu.Models.Association
  url: () ->
    '/models/' + this.model_id + "/associations"

