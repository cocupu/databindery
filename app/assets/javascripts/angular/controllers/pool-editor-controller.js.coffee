# Editable Grid
PoolEditorCtrl = ($scope, $routeParams, BinderyPool, BinderyIdentity, context) ->

  # General Scope properties
  context.initialize($routeParams.identityName, $routeParams.poolName)
  $scope.context = context
  $scope.pool = context.pool

  $scope.navigationOptions =
    [
      { id: "pool_info", name: "Pool Info"  },
      { id: "contributors", name: "Contributors" },
      { id: "audiences", name: "Audiences" },
      { id: "sources", name: "Sources" }
      { id: "indexing", name: "Indexing" }
    ]
  $scope.currentNav = $scope.navigationOptions[0]
  $scope.updatePool = (pool) ->
    pool.$update( (savedPool, putResponseHeaders) ->
      now = new Date()
      pool.lastUpdated = now.getHours()+':'+now.getMinutes().leftZeroPad(2)+':'+now.getSeconds().leftZeroPad(2)
      pool.dirty = false
    )

  $scope.addContributor = () -> $scope.pool.addContributor()
  $scope.removeContributor = (contributor) ->  $scope.pool.removeContributor(contributor)

  $scope.selectNavOption = (selection) -> $scope.currentNav = selection

PoolEditorCtrl.$inject = ['$scope', '$routeParams', 'BinderyPool', 'BinderyIdentity', 'contextService']
angular.module("curateDeps").controller('PoolEditorCtrl', PoolEditorCtrl)