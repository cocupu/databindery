angular.module("binderyCurate").directive('binderyTokenInput', () ->
  return {
    require : '?ngModel',
    restrict: 'A',
    link: (scope, element, attrs, ngModel) ->
      opts = scope.$eval(attrs.binderyTokenInput)
      # Call initSelection function so it can prepopulate the array of selections
      opts.initSelection(scope, element, (val) ->
        element.tokenInput("add", val)
      )
      lookupUrl = scope.$eval(attrs.url)
      element.tokenInput(lookupUrl, opts);
      element.bind('change', () ->
        scope.$apply( () ->
          ngModel.$setViewValue(element.val().split(","))
        )
      )
  }
)
