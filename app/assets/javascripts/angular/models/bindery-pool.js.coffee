angular.module('curateDeps').factory('BinderyPool', ['$resource', 'BinderyAudienceCategory', ($resource, BinderyAudienceCategory) ->

  BinderyPool = $resource("/:identityName/:poolName", {identityName:'@identityName', poolName:'@short_name'}, {
    update: { method: 'PUT' }
  })

  BinderyPool.prototype.loadAudienceCategories = () ->
    this.audience_categories = []
    audience_categories = this.audience_categories
    BinderyAudienceCategory.query({poolName: this.short_name, identityName:this.identityName}, (data)->
      console.log data
      audience_categories.concat(data)
    )

  BinderyPool.prototype.addContributor = () ->
    this.access_controls.push {identity:"", access:"NONE"}

  BinderyPool.prototype.removeContributor = (contributor) ->
    index = this.access_controls.indexOf(contributor);
    this.access_controls.splice(index, 1);

  return  BinderyPool
])