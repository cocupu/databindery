angular.module("binderyCurate").directive('binderyTokenInput', ['$compile',($compile) ->
  return {
    require : '?ngModel',
    restrict: 'A',
    link: (scope, element, attrs, ngModel) ->
      opts = scope.$eval(attrs.binderyTokenInput)
      scope.lookupUrl = scope.$eval(attrs.url)

      # Call initSelection function so it can prepopulate the array of selections
      if opts.initSelection
        opts.initSelection(scope, element, (val) ->
                element.tokenInput("add", val)
              )

      if opts.prePopulateFunc
        opts.prePopulate = opts.prePopulateFunc(scope, element)

      opts.onReady= () ->
        # Add ng-focus directive to the input field that was generated by tokeninput, then compile the element and add to scope
        inputtoken = element.parent().find(".token-input-input-token-facebook input").attr("ng-focus", "focusOnField(fieldConfig)")
        $compile(inputtoken)(scope)

      opts.onAdd = (item) ->
        addedToken = $(".selected-token."+item.persistent_id)
        $compile(addedToken)(scope)

      element.tokenInput(scope.lookupUrl, opts);

      # If the url changes, reset the tokeninput with the new url
      scope.$watch(() ->
        return scope.$eval(attrs.url)
      ,() ->
        scope.lookupUrl =  scope.$eval(attrs.url)
        # Remove the existing tokeninput before reloading
        element.siblings(".token-input-list-facebook").remove()
        element.tokenInput(scope.lookupUrl, opts)
      )

      element.bind('change', () ->
        scope.$apply( () ->
          ngModel.$setViewValue(element.val().split(";;"))
        )
      )
  }
])
