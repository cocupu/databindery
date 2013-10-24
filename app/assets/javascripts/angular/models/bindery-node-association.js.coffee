angular.module('curateDeps').factory('BinderyNodeAssociations', ['$resource', '$location', 'BinderyModel', 'memoService', ($resource, $location, BinderyModel, memoService) ->

  BinderyNodeAssociation = $resource("nodes/:nodeId/associations", {}, {
    update: { method: 'PUT' }
  })

  return  BinderyNodeAssociation
])