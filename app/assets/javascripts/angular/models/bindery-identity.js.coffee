angular.module('curateDeps').factory('BinderyIdentity', ['$resource', ($resource) ->

  BinderyIdentity = $resource("/identities/:name", {name:'@identityName'}, {
    update: { method: 'PUT' }
  })

  return  BinderyIdentity
])