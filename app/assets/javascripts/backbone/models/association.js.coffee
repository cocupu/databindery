class Cocupu.Models.Association extends Backbone.Model
  urlRoot : '/nodes'

  defaults:
    name: null
    node_id: null
    target_id: null


class Cocupu.Collections.AssociationsCollection extends Backbone.Collection
  model: Cocupu.Models.Association
  url: '/Associations'

