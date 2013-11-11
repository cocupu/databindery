# Editable Grid
PoolAudienceEditorCtrl = ($scope, context, BinderyAudienceCategory, BinderyAudience, BinderyIdentity) ->

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

  #
  # tokeninput config options
  #
  $scope.audienceMemberTokeninputOptions = {
    propertyToSearch: "short_name"
#    jsonContainer: ""
    preventDuplicates: true
    theme: "facebook"
    resultsFormatter: (item) ->
      return "<li>"+item.name+" ("+item.short_name+")</li>"
    tokenFormatter: (item) ->
      if item.name
        name = item.name+" ("+item.short_name+")"
      else
        name = item.short_name
      fieldHtml = "<li class=\"selected-token "+item.id+"\" ng-click=\"openNodeSupplemental('"+item.id+"')\" ng-focus=\"focusOnField(fieldConfig)\">"+name+"</li>"
      return fieldHtml
    # initialize selections within the tokeninput element
    # @param scope of the directive
    # @param element the directive is attached to
    # @param callback to trigger for each JSON object that should be added to the array of selections
    initSelection: (scope, element, callback) ->
      ids = scope.$eval(element.attr("ng-model"))
      angular.forEach(ids, (name) ->
        identity = BinderyIdentity.get({name:name}, () ->
          callback(identity)
        )
      )

  }
PoolAudienceEditorCtrl.$inject = ['$scope', 'contextService', 'BinderyAudienceCategory', 'BinderyAudience', 'BinderyIdentity']
angular.module("curateDeps").controller('PoolAudienceEditorCtrl', PoolAudienceEditorCtrl)