angular.module('curateDeps').factory('contextService', ['BinderyPool', 'BinderyIdentity', (BinderyPool, BinderyIdentity) ->
  contextService = {pool:"", poolIdentity:""}

  contextService.initialize = (identityName, poolName) ->
    # Only load resources if identityName is actually set
    if identityName
      contextService.identityName = identityName
      contextService.poolName = poolName
      contextService.pool = BinderyPool.get({identityName: identityName, poolName: poolName}, (data) -> )
      contextService.poolIdentity = BinderyIdentity.get({name: identityName}, (data) -> )

  return contextService
])