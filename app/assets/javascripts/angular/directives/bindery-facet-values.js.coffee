angular.module("binderyCurate").directive('binderyFacetValues', ['$compile',($compile) ->
  return {
    restrict: 'E'
    template: '<ul></ul>'
    replace: true
    scope: {
      values: '='
    }
    link: (scope, element, attrs) ->
      scope.$watch('values', (newValue, oldValue) ->
        if (newValue)
          blacklightFacetFieldArray = scope.values # scope.$eval(attrs.values)

        # Parse blacklight's facet field array into an array of facetField objects
        if typeof(blacklightFacetFieldArray) != "undefined"
          facetFields = $.map(blacklightFacetFieldArray, (ff, i) ->
            if (i%2 == 0)
              return {value: ff, count: blacklightFacetFieldArray[i+1]}
          )
        else
          facetFields = []

        # Empty out the Facet list and re-draw with the new values
        element.empty()
        angular.forEach(facetFields, (ff) ->
          li = document.createElement('li');
          link = $("<a>", {text:ff.value, title:ff.value, href:"#" }).appendTo(li)
          $("<span class='badge pull-right'>").text(ff.count).appendTo(link)
          element[0].appendChild(li)
        )
      , false)
  }
])