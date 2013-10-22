# Editable Grid
GridWithHeadsupCtrl = ($scope, $http, $location, BinderyNode, BinderyModel) ->

  # General Scope properties
  $scope.selectedNodes = []
  $scope.currentNode = {}
  $scope.currentModel = {}

  $scope.searchUrl = $location.path()
  $scope.detailPanelState = "node"
  $scope.infoPanelState = "default"
  $scope.supplementalPanelState = "none"
  $scope.supplementalNode = {}
  $scope.focusedField = {}


  $scope.typeOptionsFor = (fieldType) ->
    associationTypes = [{label:"Associaton (Has Many)", id:"Has Many"}, {label:"Associaton (Has One)", id:"Has One"}]
    fieldTypes = [{label:"Text Field", id:"text"},{label:"Text Area", id:"textarea"}, {label:"Date", id:"date"}]
    if (["Has One", "Has Many"].indexOf(fieldType) > -1)
      return associationTypes
    else
      return fieldTypes

  $scope.currentModel = BinderyModel.get({modelId:$("#model-chooser .active").data("model-id")}, (m, getResponseHeaders) -> $scope.columnDefs = m.columnDefsFromModel() )


  $scope.updateModel = (model) ->
    model.$update( (savedModel, putResponseHeaders) ->
      now = new Date()
      model.lastUpdated = now.getHours()+':'+now.getMinutes().leftZeroPad(2)+':'+now.getSeconds().leftZeroPad(2)
      model.dirty = false
    )

  $scope.updateNode = (node) ->
    nodeResource = new BinderyNode(node)
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
    resultsFormatter: (item) ->
      return "<li>"+item.title+"</li>"
    tokenFormatter: (item) ->
      switch item.file_type
        when "audio"
          fieldHtml = "<li class=\"selected-token file audio "+item.persistent_id+"\" ng-click=\"openNodeSupplemental('"+item.persistent_id+"')\" ng-focus=\"focusOnField(fieldConfig)\"><audio controls><source src=\""+item.download_url()+"\" type=\"audio/mpeg\"></source></audio><div class=\"token-info\">"+item.title+"<br/>"+item.data['content-type']+"</div></li>"
        when "video"
          fieldHtml = "<li class=\"selected-token file video "+item.persistent_id+"\" ng-click=\"openNodeSupplemental('"+item.persistent_id+"')\" ng-focus=\"focusOnField(fieldConfig)\"><video controls><source src=\""+item.download_url()+"\" type=\"video/mp4\"></source></video><div class=\"token-info\">"+item.title+"</div></li>"
        when "spreadsheet"
          fieldHtml = "<li class=\"selected-token file spreadsheet "+item.persistent_id+"\" ng-click=\"openNodeSupplemental('"+item.persistent_id+"')\" ng-focus=\"focusOnField(fieldConfig)\"><div class=\"token-info\">"+item.title+"</div></li>"
        when "generic"
          fieldHtml = "<li class=\"selected-token file generic "+item.persistent_id+"\" ng-click=\"openNodeSupplemental('"+item.persistent_id+"')\" ng-focus=\"focusOnField(fieldConfig)\"><div class=\"token-info\">"+item.title+"</div></li>"
        else
          fieldHtml = "<li class=\"selected-token "+item.persistent_id+"\" ng-click=\"openNodeSupplemental('"+item.persistent_id+"')\" ng-focus=\"focusOnField(fieldConfig)\">"+item.title+"</li>"

      return fieldHtml

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
  $scope.columnDefs = []
  $scope.columnDefsFromModel = () -> $scope.currentModel.columnDefs()

  $scope.filterOptions =
    filterText: "",
    useExternalFilter: true

  $scope.totalServerItems = 0
  $scope.pagingOptions =
    pageSizes: [25, 50, 100, 250, 500, 1000],
    pageSize: 25,
    currentPage: 1

  $scope.setPagingData = (data, page, pageSize) ->
#      pagedData = data.aaData.slice((page - 1) * pageSize, page * pageSize)
    $scope.searchResponse = data
    $scope.docs = data.docs;
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
    data: 'docs'
    selectedItems: $scope.selectedNodes
    selectedIndex: $scope.selectedCellIndex
    multiSelect: false
    enableCellSelection: true
    enableCellEdit: false
    enableRowSelection: true
    columnDefs: 'columnDefs'
    rowHeight: "50"
    enablePaging: true,
    showFooter: true,
    footerRowHeight: "30",
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


  $scope.focusOnField = (fieldConfig) ->
    $scope.focusedField  = fieldConfig
    $scope.supplementalPanelState = "field"


  $scope.configField = (fieldConfig) ->
    $scope.focusedField  = fieldConfig
    $scope.supplementalPanelState = "model"
    window.setTimeout(() ->
      $("#modelField_"+fieldConfig.code+"_name").focus()
    ,100)

  $scope.openNodeSupplemental = (pid) ->
    $scope.supplementalNode = Node.get({nodeId:pid}, (node) ->
      $scope.supplementalPanelState = "node"
    )

  #
  $scope.resizeGrid = () ->
    staticElementsHeight = $(".row").height() + $(".headsup").not(":hidden").height() + $(".navbar-fixed-top").height() + $(".navbar-fixed-bottom").height()
    newHeight = Math.max(100, $(window).height() - staticElementsHeight)
    $(".ngGrid").height(newHeight)

  # Trigger on load and  when page resizes
  $( document ).ready( () -> $scope.resizeGrid() )
  $( window ).resize( () ->
    $scope.resizeGrid()
  )

GridWithHeadsupCtrl.$inject = ['$scope', '$http', '$location', 'BinderyModel', "BinderyNode"]
angular.module("curateDeps").controller('GridWithHeadsupCtrl', GridWithHeadsupCtrl)