# Editable Grid
PoolAudienceEditorCtrl = ($scope, context, BinderyAudienceCategory, BinderyAudience) ->

  # General Scope properties
  $scope.pool = context.pool
  $scope.audienceCategories = BinderyAudienceCategory.query({identityName:context.identityName, poolName:context.poolName}, (data) ->
    angular.forEach(data, (item, idx) ->
      item.reifyAudiences()
    )
  )

  $scope.selectedCategory = "everyone"

  $scope.selectCategory = (selection) -> $scope.selectedCategory = selection
  $scope.newCategory = () ->
    newCategory = new BinderyAudienceCategory(identity_name:context.identityName, pool_name:context.poolName)
    $scope.audienceCategories.push(newCategory)
    $scope.selectCategory(newCategory)
  $scope.updateCategory = (category) -> category.update()

  $scope.addAudienceToCategory = (category) ->
    newAudience = new BinderyAudience(identity_name:context.identityName, pool_name:context.poolName, audience_category_id:category.id)
    category.audiences.push(newAudience)

PoolAudienceEditorCtrl.$inject = ['$scope', 'contextService', 'BinderyAudienceCategory', 'BinderyAudience']
angular.module("curateDeps").controller('PoolAudienceEditorCtrl', PoolAudienceEditorCtrl)