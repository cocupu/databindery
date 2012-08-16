@Cocupu = {
  views:  {
    entityAsListItem: (entity) ->
      HandlebarsTemplates['node_list_item'](entity: entity, data: entity.data, model: entity.data.model, title: entity.data.title, id: entity.id())
  }

  controllers:  { }

  models: { }
            
}

Handlebars.registerHelper('linkTo', (text, resource) ->
  text = Handlebars.Utils.escapeExpression(text)
  url  = Handlebars.Utils.escapeExpression(resource.toPath())
  result = '<a href="' + url + '">' + text + '</a>'
  return new Handlebars.SafeString(result)
)

Handlebars.registerHelper('getValue', (name, source, key) ->
  val =  Handlebars.Utils.escapeExpression(source.data[key])
  if val
    return new Handlebars.SafeString("<dt>" + name + "</dt>" + "<dd>" + val + "</dd>")
)

class Cocupu.models.Model
  @base_url:  '/models'
  id: ->
    @data.id
  entities: (handlers) ->
    Cocupu.models.Entity.all(url: Model.base_url + '/' + @id() + '/nodes', success: handlers.success)
  constructor: (data) ->
    @data = data 


class Cocupu.models.Entity
  @base_url:  '/nodes'
  # attrs 
  #   url: the url to fetch, defaults to @base_url
  #   success: the success handler
  @all: (attrs) ->
    url = attrs.url || @base_url
    $.getJSON attrs.url, (data) ->
      items = []
      $.each data, (n, key) ->
        items.push new Cocupu.models.Entity(key)
      attrs.success(items)
  id: ->
    @data.id
  toPath: ->
    Entity.base_url + '/' + @id()
  constructor: (@data) ->


Cocupu.controllers.searchEntities = (model_id) ->
  successHandler = (data) ->
      $.each data, (n, key) ->
        $('ul.model_instances').append(Cocupu.views.entityAsListItem(key))
  if model_id
    model = new Cocupu.models.Model(id: model_id)
    model.entities(success: successHandler)
  else
    Cocupu.models.Entity.all(success: successHandler) 
    
