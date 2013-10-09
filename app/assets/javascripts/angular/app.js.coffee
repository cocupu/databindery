app = angular.module('binderyCurate', ["binderyEditableGrid"])
app.config( ($routeProvider, $locationProvider) ->
  # enable html5Mode for pushstate ('#'-less URLs)
  $locationProvider.html5Mode(true);
  $locationProvider.hashPrefix('!');
)