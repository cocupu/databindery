class Cocupu.Models.DataSource extends Backbone.Model
  urlRoot : '/drives'

  defaults:
    title: null
    owner: null
    bindings: null

  initialize: (attributes, options) ->
      options || (options = {})
      this.bind("error", this.errorHandler)
      this.init && this.init(attributes, options)

  errorHandler: (model, error) ->
    if error.status == 401 || error.status == 403
      #console.log jQuery.parseJSON( error.responseText )["redirect"]
      window.location.href = jQuery.parseJSON( error.responseText )["redirect"]
      

class Cocupu.Collections.DataSourcesCollection extends Backbone.Collection
  model: Cocupu.Models.DataSource
  url: ->
    '/' + window.router.identity + '/' + window.router.pool.short_name + '/drives'


  initialize: (attributes, options) ->
      options || (options = {})
      this.bind("error", this.errorHandler)
      this.init && this.init(attributes, options)

  errorHandler: (model, error) ->
    if error.status == 401 || error.status == 403
      #console.log jQuery.parseJSON( error.responseText )["redirect"]
      window.location.href = jQuery.parseJSON( error.responseText )["redirect"]

