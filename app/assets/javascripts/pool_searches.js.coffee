jQuery ->
  $('#documents.grid').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#documents.grid').data('source')
    sScrollY: 400
    sScrollX: "850px"
    sScrollXInner: "900px"
    bScrollInfinite: true
    bScrollCollapse: true
    aoColumnDefs: [
      { bSortable: false, aTargets: [ "_all" ] }
#      { aTargets: ["_all"], fnCreatedCell: (nTd, sData, oData, iRow, iCol) ->
#        columnTitle = $('#documents thead th:eq('+iCol+')').text()
#        $(nTd).attr("data-title", columnTitle )
#      }
    ]

#  From http://zurb.com/playground/playground/responsive-tables/responsive-tables.js
#  $(document).ready () ->
#    switched = false;
#    updateTables = () ->
#      if ($(window).width() < 767) && !switched
#        switched = true;
#        $("table.responsive").each (i, element) ->
#          splitTable($(element))
#        return true
#      else if switched && ($(window).width() > 767)
#        switched = false;
#        $("table.responsive").each (i, element)  ->
#          unsplitTable($(element));
#
#    $(window).load(updateTables);
#    $(window).bind("resize", updateTables);
#
#
#    splitTable = (original) ->
#      original.wrap("<div class='table-wrapper' />")
#      copy = original.clone()
##      copy.find("td, th").not("td:first-child, th:first-child, td:nth-child(2), th:nth-child(2)").css("display","none")
#      copy.find("td, th").not("td:first-child, th:first-child").css("display","none")
#      copy.removeClass("responsive")
#
#      original.closest(".table-wrapper").append(copy)
#      copy.wrap("<div class='pinned' />")
#      original.wrap("<div class='scrollable' />")
#
#    unsplitTable = (original) ->
#      original.closest(".table-wrapper").find(".pinned").remove();
#      original.unwrap();
#      original.unwrap();





