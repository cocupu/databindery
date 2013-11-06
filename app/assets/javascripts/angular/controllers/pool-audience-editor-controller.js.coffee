# Editable Grid
PoolAudienceEditorCtrl = ($scope) ->

  # General Scope properties
  $scope.audienceCategories =
    [
      { name: "Everyone (all visitors)", order_relevant:false  }
    ]
  $scope.selectedCategory = $scope.audienceCategories[0]

  $scope.selectCategory = (selection) -> $scope.selectedCategory = selection
  $scope.newCategory = () ->
    newCategory = { name:"", audiences: []}
    $scope.audienceCategories.push(newCategory)
    $scope.selectCategory(newCategory)

  $scope.addAudienceToCategory = (category) ->  category.audiences.push({name:"", filters:[], members:[]})


PoolAudienceEditorCtrl.$inject = ['$scope']
angular.module("curateDeps").controller('PoolAudienceEditorCtrl', PoolAudienceEditorCtrl)