angular.module('curateDeps').factory('BinderyPool', ['$resource', ($resource) ->

  BinderyPool = $resource("/:identityName/:poolName", {identityName:'@identityName', poolName:'@short_name'}, {
    update: { method: 'PUT' }
  })

  BinderyPool.prototype.addContributor = () ->
    this.access_controls.push {identity:"", access:"NONE"}

  BinderyPool.prototype.removeContributor = (contributor) ->
    index = this.access_controls.indexOf(contributor);
    this.access_controls.splice(index, 1);

  return  BinderyPool
])