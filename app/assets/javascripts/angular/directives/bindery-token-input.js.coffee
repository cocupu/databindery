angular.module("binderyCurate").directive('binderyTokenInput', () ->
  return {
    require : '?ngModel',
    restrict: 'A',
    link: (scope, element, attrs, ngModel) ->
      tokenInputOptions = scope.$eval(attrs.binderyTokenInput)
      # Call initSelection function so it can prepopulate the array of selections
      tokenInputOptions.initSelection(scope, element, (val) ->
        element.tokenInput("add", val)
      )
      element.tokenInput(attrs.url, tokenInputOptions);
      element.bind('change', () ->
        scope.$apply( () ->
          ngModel.$setViewValue(element.val().split(","))
        )
      )
  }
)
