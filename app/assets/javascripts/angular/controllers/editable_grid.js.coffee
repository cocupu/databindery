# Editable Grid
angular.module("binderyEditableGrid",['ngGrid', "ngResource", "ngSanitize"]).controller('EditableGridCtrl', ($scope, $http, $location, $resource, $sanitize, $log) ->
  $scope.selectedNodes = []
  $scope.selectedCellIndex =  0
  Model = $resource('/models/:modelId', {modelId:'@model-id'});
  $scope.currentModel = Model.get({modelId:$("#model-chooser .active").data("model-id")}, () -> $scope.columnDefs = $scope.columnDefsFromModel() )
  $scope.columnDefs = []
  $scope.columnDefsFromModel = () ->
    fieldsDefs = $.map($scope.currentModel.fields, (f, i) ->
      return {
      field:"data['"+$sanitize(f.code)+"']"
      displayName:f.name
      width:"120"
      enableCellEdit: true
#                editableCellTemplate: '/assets/editField-textarea.html'
      editableCellTemplate: '/assets/editField-textfield.html'

#                editableCellTemplate: '<input type="text" ng-model="row.entity.data[\''+$sanitize(f.code)+'\']"></input>'
      }
    )
    associationsDefs = $.map($scope.currentModel.associations, (f, i) ->
      return {field:"associations['"+$sanitize(f.code)+"']", displayName:f.name, width:"120", enableCellEdit: true}
    )
    return fieldsDefs.concat(associationsDefs)
  #      modelAssociationsAndFields = $scope.currentModel.fields.concat($scope.currentModel.associations)
  #      return $.map(modelAssociationsAndFields, (f, i) ->
  #          return {field:$sanitize(f.code), displayName:f.name, minWidth:"120", enableCellEdit: true}
  #      )

  $scope.filterOptions =
    filterText: "",
    useExternalFilter: true

  $scope.totalServerItems = 0
  $scope.pagingOptions =
    pageSizes: [250, 500, 1000],
    pageSize: 250,
    currentPage: 1

  $scope.setPagingData = (data, page, pageSize) ->
#      pagedData = data.aaData.slice((page - 1) * pageSize, page * pageSize)
    $scope.myData = data.docs;
    $scope.totalServerItems = data.response.numFound;
    if (!$scope.$$phase)
      $scope.$apply()

  $scope.getPagedDataAsync = (pageSize, page, searchText) ->
    setTimeout( (() ->
      if (searchText)
        ft = searchText.toLowerCase()
      else
        ft = ""
      $http.get($location.absUrl(), {
        params: {
          rows: pageSize
          page: page
          q: searchText
        }
      }).success( (data) ->
        $scope.setPagingData(data,page,pageSize);
      )
    ), 100)

  $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage)

  $scope.$watch('pagingOptions', ((newVal, oldVal) ->
    if (newVal != oldVal && newVal.currentPage != oldVal.currentPage)
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage, $scope.filterOptions.filterText)
  ), true)

  $scope.$watch('filterOptions', ((newVal, oldVal) ->
    if (newVal != oldVal)
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage, $scope.filterOptions.filterText);
  ), true);


  setGridOptions = () ->

  $scope.gridOptions =
    data: 'myData'
    selectedItems: $scope.selectedNodes
    selectedIndex: $scope.selectedCellIndex
    multiSelect: false
    enableCellSelection: true
    enableCellEdit: true
    enableRowSelection: true
    columnDefs: 'columnDefs'
    rowHeight: "100"
    enablePaging: true,
    showFooter: true,
    totalServerItems: 'totalServerItems',
    pagingOptions: $scope.pagingOptions,
    filterOptions: $scope.filterOptions
)