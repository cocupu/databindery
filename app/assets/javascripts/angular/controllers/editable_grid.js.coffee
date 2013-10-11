# Editable Grid
EditableGridCtrl = ($scope, $http, $location, $resource, $sanitize, $log) ->

  $scope.searchUrl = $location.path()
  #
  # Resources
  #
  Model = $resource('/models/:modelId', {modelId:'@id'}, {
    update: { method: 'PUT' }
  })
  $scope.typeOptionsFor = (fieldType) ->
    associationTypes = [{label:"Associaton (Has Many)", id:"Has Many"}, {label:"Associaton (Has One)", id:"Has One"}]
    fieldTypes = [{label:"Text Field", id:"text"},{label:"Text Area", id:"textarea"}, {label:"Date", id:"date"}]
    if (["Has One", "Has Many"].indexOf(fieldType) > -1)
      return associationTypes
    else
      return fieldTypes

  $scope.updateModel = (model) ->
    model.$update( (savedModel, putResponseHeaders) ->
      now = new Date()
      model.lastUpdated = now.getHours()+':'+now.getMinutes().leftZeroPad(2)+':'+now.getSeconds().leftZeroPad(2)
      model.dirty = false
    )

  Node = $resource($location.path().replace("search","nodes")+"/:nodeId", {nodeId:'@persistent_id'}, {
    update: { method: 'PUT' }
  })

  $scope.updateNode = (node) ->
    nodeResource = new Node(node)
    nodeResource.$update( (savedNode, putResponseHeaders) ->
      now = new Date()
      node.lastUpdated = now.getHours()+':'+now.getMinutes().leftZeroPad(2)+':'+now.getSeconds().leftZeroPad(2)
      node.dirty = false
    )


  #
  # tokeninput config options
  #
  $scope.nodeTokeninputOptions = {
    propertyToSearch: "title"
    jsonContainer: "docs"
    preventDuplicates: true
    theme: "facebook"
    # initialize selections within the tokeninput element
    # @param scope of the directive
    # @param element the directive is attached to
    # @param callback to trigger for each JSON object that should be added to the array of selections
    initSelection: (scope, element, callback) ->
      ids = scope.$eval(element.attr("ng-model"))
      angular.forEach(ids, (pid) ->
        node = Node.get({nodeId:pid}, () ->
          node.id = node.persistent_id
          callback(node)
        )
      )
  }

  #
  # ng-grid Configs
  #
  $scope.selectedNodes = []
  $scope.currentNode = {}

  $scope.currentModel = Model.get({modelId:$("#model-chooser .active").data("model-id")}, () -> $scope.columnDefs = $scope.columnDefsFromModel() )

  $scope.columnDefs = []
  $scope.columnDefsFromModel = () ->
    if $scope.currentModel.fields.length + $scope.currentModel.associations.length > 5
      fixedColumnWidth = true
    fieldsDefs = $.map($scope.currentModel.fields, (f, i) ->
      columnDef = {
        field:"data['"+$sanitize(f.code)+"']"
        displayName:f.name
#        editableCellTemplate: '/assets/editField-textarea.html'
        editableCellTemplate: '/assets/editField-textfield.html'
#        editableCellTemplate: '<input type="text" ng-model="row.entity.data[\''+$sanitize(f.code)+'\']"></input>'
      }
      if fixedColumnWidth
        columnDef["width"] = "120"
      return columnDef
    )
    associationsDefs = $.map($scope.currentModel.associations, (f, i) ->
      columnDef = {field:"associations['"+$sanitize(f.code)+"']", displayName:f.name, width:"120"}
      if fixedColumnWidth
        columnDef["width"] = "120"
      return columnDef
    )
    return fieldsDefs.concat(associationsDefs)

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
    enableCellEdit: false
    enableRowSelection: true
    columnDefs: 'columnDefs'
    rowHeight: "30"
    enablePaging: true,
    showFooter: false,
    totalServerItems: 'totalServerItems',
    pagingOptions: $scope.pagingOptions,
    filterOptions: $scope.filterOptions,
    afterSelectionChange: (rowItem, event) ->
      if ($scope.currentNode == rowItem)
#        This is where we could focus on field control corresponding to selected cell
        selectedCell = $('.ngCellElement:focus')
        if (selectedCell.length > 0)
          selectedCol = selectedCell.attr('class').split(" ").filter( (x) -> return x.indexOf("colt") > -1 )[0]
          $(".fieldControl."+selectedCol).focus()
      else
        $scope.currentNode = rowItem

EditableGridCtrl.$inject = ['$scope', '$http', '$location', '$resource', '$sanitize', '$log']
angular.module("binderyEditableGrid", ['ng','ngGrid', "ngResource", "ngSanitize"]).controller('EditableGridCtrl', EditableGridCtrl)