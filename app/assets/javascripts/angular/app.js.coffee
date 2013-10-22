app = angular.module('binderyCurate', ['curateDeps'])
dep = angular.module('curateDeps', ['ng', "ngResource", "ngSanitize"])

app.config( ['$routeProvider', '$locationProvider', '$httpProvider', ($routeProvider, $locationProvider, $httpProvider) ->
  # enable html5Mode for pushstate ('#'-less URLs)
  $locationProvider.html5Mode(true);
  $locationProvider.hashPrefix('!');

  # Use Rails csrf token with http requests
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])

