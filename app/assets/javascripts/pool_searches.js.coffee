app = angular.module('binderyCurate', ['ngGrid']);
app.controller('EditableGrid', ($scope, $http, $location) ->
    $scope.selectedNode = []

    $scope.filterOptions =
      filterText: "",
      useExternalFilter: true

    $scope.totalServerItems = 0
    $scope.pagingOptions =
      pageSizes: [250, 500, 1000],
      pageSize: 250,
      currentPage: 1

    $scope.setPagingData = (data, page, pageSize) ->
      pagedData = data.slice((page - 1) * pageSize, page * pageSize)
      $scope.myData = pagedData;
      $scope.totalServerItems = data.length;
      if (!$scope.$$phase)
        $scope.$apply()

    $scope.getPagedDataAsync = (pageSize, page, searchText) ->
      setTimeout( (() ->
        if (searchText)
          ft = searchText.toLowerCase();
          $http.get($location.path(), {
            rows: pageSize
            page: page
            q: searchText
          }).success( (largeLoad) ->
            $scope.setPagingData(data,page,pageSize);
          )
        else
          $http.get($location.path()).success( (largeLoad) ->
            $scope.setPagingData(largeLoad,page,pageSize)
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



    $scope.gridOptions =
      data: 'myData'
      selectedItems: $scope.selectedNode
      multiSelect: false
#      columnDefs: [{field:'name', displayName:'Name'}, {field:'age', displayName:'Age'}]
      enablePaging: true,
      showFooter: true,
      totalServerItems: 'totalServerItems',
      pagingOptions: $scope.pagingOptions,
      filterOptions: $scope.filterOptions
)
