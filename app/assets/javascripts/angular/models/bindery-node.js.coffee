angular.module('curateDeps').factory('BinderyNode', ['$resource', '$location', ($resource, $location) ->

  BinderyNode = $resource($location.path().replace("search","nodes")+"/:nodeId", {nodeId:'@persistent_id'}, {
      update: { method: 'PUT' }
  })

  BinderyNode.prototype.download_url = () ->  $location.path().replace("search","file_entities")+"/"+this.persistent_id

  return BinderyNode
])