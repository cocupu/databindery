angular.module("binderyNodeAssociation",['ui.select2']).controller('NodeAssociationCtrl', function($scope, $http) {

    $scope.init = function(model_id)
    {
        $scope.model_id = model_id;
    };

    // Built-in support for ajax
    $scope.select2options = {
        formatResult: nodeFormatResult, // omitted for brevity, see the source of this page
        formatSelection: nodeFormatSelection,  // omitted for brevity, see the source of this page
        dropdownCssClass: "bigdrop", // apply css that makes the dropdown taller
        escapeMarkup: function (m) { return m; }, // we do not want to escape markup since we are displaying html in results
        ajax: {
            url: "/matt/footest/search",
            data: function (term, page) {
                queryParams = {
                    q: term
                }
                if (typeof($scope.model_id) != "undefined") {
                    queryParams["model_id"] = $scope.model_id;
                }

                return queryParams;
            },
            results: function (data, page) {
                // parse the results into the format expected by Select2.
                // since we are using custom formatting functions we do not need to alter remote JSON data
                return {results: data["docs"]};
            }
        },
        initSelection: function(element, callback) {
            var ids = $(element).val().split(",");
            var collectedJson = [];
            for (var i = 0; i < ids.length; i++) {
                $.ajax("/matt/footest/nodes/"+ids[i]+".json", {
                    data: {
                    },
                }).done(function(data) {
                    data["id"] = data["persistent_id"];
                    callback(data);
//                    collectedJson.push(data);
                });
            }
//            callback(collectedJson);
        }

    }

    function nodeFormatResult(node) {
        var markup = "<table class='node-result'><tr>";
        if (node.posters !== undefined && node.posters.thumbnail !== undefined) {
            markup += "<td class='node-image'><img src='" + node.posters.thumbnail + "'/></td>";
        }
        markup += "<td class='node-info'><div class='node-title'>" + node.title + "</div>";
        if (node.critics_consensus !== undefined) {
            markup += "<div class='node-synopsis'>" + node.critics_consensus + "</div>";
        }
        else if (node.synopsis !== undefined) {
            markup += "<div class='node-synopsis'>" + node.synopsis + "</div>";
        } else {
            markup += "<div class='node-title'>" + node.title + "</div>";
        }
        markup += "</td></tr></table>"
        return markup;
    }

    function nodeFormatSelection(node) {
        return node.title;
    }
});

